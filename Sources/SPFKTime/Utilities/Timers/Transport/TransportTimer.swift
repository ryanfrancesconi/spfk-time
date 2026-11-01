// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-time

#if os(macOS)

    // Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-time

    import AppKit
    import AVFoundation
    import SPFKBase
    import SPFKUtils
    import SwiftExtensions
    import SwiftTimecode

    /// TransportTimer is a facade that wraps a platform-appropriate display link timer and bridges it
    /// to the audio synchronization domain via AVAudioTime / mach_absolute_time.
    public class TransportTimer {
        /// Closure receiving ``TransportTimerEvent`` values (state changes and time updates).
        public var eventHandler: ((TransportTimerEvent) -> Void)?

        /// `true` when the transport is paused (position preserved for resume).
        public private(set) var isPaused: Bool = false

        /// The current position of the playhead in source seconds. Can only be set when the timer
        /// isn't running.
        public var currentTime: TimeInterval = 0

        /// The position as a function of host time, set by a start.
        public private(set) var clock = TransportClock(hostTime: AVAudioTime.seconds(forHostTime: mach_absolute_time()))

        /// The host time at which the position would be zero at the current rate.
        public var avStartTime: AVAudioTime {
            AVAudioTime(hostTime: AVAudioTime.hostTime(forSeconds: max(0, clock.origin)))
        }

        /// Source seconds per second of playback.
        public var rate: Double { clock.rate }

        private let internalTimer: TimerModel

        /// The host clock, injectable for tests.
        var hostClock: () -> UInt64 = { mach_absolute_time() }

        // MARK: - Init

        /// Creates a transport timer bound to the display containing the given view.
        @MainActor public init(on view: NSView) {
            defer {
                internalTimer.eventHandler = { [weak self] in self?.handleTimerUpdateEvent() }
            }

            if #available(macOS 14, *) {
                internalTimer = DisplayLinkTimer(on: view)
                return
            }

            internalTimer = LegacyDisplayLinkTimer(onQueue: .main)
        }

        /// Creates a transport timer bound to the display containing the given window.
        @MainActor public init(on window: NSWindow) {
            defer {
                internalTimer.eventHandler = { [weak self] in self?.handleTimerUpdateEvent() }
            }

            if #available(macOS 14, *) {
                internalTimer = DisplayLinkTimer(window: window)
                return
            }

            internalTimer = LegacyDisplayLinkTimer(onQueue: .main)
        }

        /// Creates a transport timer bound to the given screen.
        @MainActor public init(screen: NSScreen? = NSScreen.screens.first) throws {
            guard let screen else {
                throw NSError(description: "Failed to get NSScreen for display link")
            }

            defer {
                internalTimer.eventHandler = { [weak self] in self?.handleTimerUpdateEvent() }
            }

            if #available(macOS 14, *) {
                internalTimer = DisplayLinkTimer(screen: screen)
                return
            }

            internalTimer = LegacyDisplayLinkTimer(onQueue: .main)
        }

        @available(macOS, deprecated: 14.0, message: "Use view based timer")
        public init(dispatchQueue: DispatchQueue) {
            internalTimer = LegacyDisplayLinkTimer(onQueue: dispatchQueue)
            internalTimer.eventHandler = { [weak self] in self?.handleTimerUpdateEvent() }
        }

        /// Internal initializer for testing with an injected timer
        init(timer: TimerModel) {
            internalTimer = timer
            internalTimer.eventHandler = { [weak self] in self?.handleTimerUpdateEvent() }
        }

        /// Permanently stops the timer and releases the event handler.
        public func dispose() {
            internalTimer.dispose()
            eventHandler = nil
        }

        /// Received event from the timer, called on the screen refresh rate
        private func handleTimerUpdateEvent() {
            let now = AVAudioTime.seconds(forHostTime: hostClock())

            if clock.applyChanges(through: now) > 0 {
                send(event: .retimed(rate: clock.rate, originHostTime: avStartTime.hostTime))
            }

            currentTime = clock.position(at: now)

            send(event: .time(currentTime))
        }

        /// Starts playback with `time` heard at `hostTime`, advancing at `rate` source seconds per
        /// second. Before `hostTime` the position stays at `time`.
        ///
        /// - Parameters:
        ///   - time: The start position in source seconds.
        ///   - hostTime: Optional `mach_absolute_time` anchor; defaults to now.
        ///   - rate: Source seconds per second of playback.
        public func start(
            at time: TimeInterval,
            hostTime: UInt64? = nil,
            rate: Double = 1
        ) {
            guard !isRunning else {
                Log.error("Transport is already running")
                return
            }

            let hostTime = hostTime ?? hostClock()
            clock = TransportClock(position: time, hostTime: AVAudioTime.seconds(forHostTime: hostTime), rate: rate)
            currentTime = time
            resumeAndSendStart()
        }

        /// Starts playback with position zero at `avTime`, keeping the current rate and any scheduled
        /// rate change.
        public func start(avTime: AVAudioTime) {
            clock.reanchor(position: 0, hostTime: AVAudioTime.seconds(forHostTime: avTime.hostTime))
            resumeAndSendStart()
        }

        /// Starts again with `time` heard at `hostTime`, at the rate reached by then and keeping any
        /// later scheduled change, as a loop's wrap does. Before `hostTime` the position stays at `time`.
        public func restart(at time: TimeInterval, hostTime: UInt64) {
            clock.reanchor(position: time, hostTime: AVAudioTime.seconds(forHostTime: hostTime))
            currentTime = time
            resumeAndSendStart()
        }

        /// Schedules a new rate while running, first heard at `hostTime`. The position folds there,
        /// continuous, and ``TransportTimerEvent/retimed(rate:originHostTime:)`` is sent on the first
        /// tick that reaches it.
        public func retime(rate: Double, atHostTime hostTime: UInt64) {
            guard isRunning else { return }
            clock.changeRate(to: rate, at: AVAudioTime.seconds(forHostTime: hostTime))
        }

        /// The source position heard at `hostTime`, scheduled rate changes included.
        public func position(atHostTime hostTime: UInt64) -> TimeInterval {
            clock.position(at: AVAudioTime.seconds(forHostTime: hostTime))
        }

        /// The host time at which source position `time` is heard.
        public func hostTime(forSource time: TimeInterval) -> UInt64 {
            AVAudioTime.hostTime(forSeconds: max(0, clock.hostTime(forPosition: time)))
        }

        private func resumeAndSendStart() {
            internalTimer.resume()
            send(event: .state(.start))
        }

        /// Stops playback and resets the transport. No-op if not running.
        public func stop() {
            guard isRunning else { return }

            internalTimer.suspend()
            send(event: .state(.stop))
        }

        /// Pauses playback, preserving the current position for later resume.
        public func pause() {
            guard isRunning else { return }

            internalTimer.suspend()
            isPaused = true
            send(event: .state(.pause))
        }

        /// Resumes playback from the paused position. No-op if not paused.
        public func resume() {
            guard isPaused else { return }
            isPaused = false

            clock = TransportClock(
                position: currentTime, hostTime: AVAudioTime.seconds(forHostTime: hostClock()), rate: clock.rate
            )

            internalTimer.resume()
            send(event: .state(.resume))
        }
    }

    extension TransportTimer {
        /// `true` when the display-link timer is actively firing.
        public var isRunning: Bool {
            internalTimer.state == .resumed
        }

        /// The effective refresh rate of the underlying display-link timer.
        public var fps: Double {
            internalTimer.fps
        }

        fileprivate func send(event: TransportTimerEvent) {
            eventHandler?(event)
        }
    }

#endif
