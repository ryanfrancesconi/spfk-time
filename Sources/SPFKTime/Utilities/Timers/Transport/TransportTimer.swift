#if os(macOS)

    // Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-time

    import AppKit
    import AVFoundation
    import SPFKBase
    import SPFKUtils
    import SwiftExtensions
    import SwiftTimecode

    /// Transport​Timer is a facade that wraps a platform-appropriate display link timer and bridges it
    /// to the audio synchronization domain via AVAudio​Time / mach​_absolute​_time.
    public class TransportTimer {
        /// Closure receiving ``TransportTimerEvent`` values (state changes and time updates).
        public var eventHandler: ((TransportTimerEvent) -> Void)?

        /// `true` when the transport is paused (position preserved for resume).
        public private(set) var isPaused: Bool = false

        /// The current position of the playhead in fractional seconds.
        /// This is real time seconds. Can only be set when the timer isn't running.
        public var currentTime: TimeInterval = 0

        private var avStartTime = AVAudioTime.now()

        private let internalTimer: TimerModel

        // MARK: - Init

        /// Creates a transport timer bound to the display containing the given view.
        @MainActor public init(on view: NSView) {
            defer {
                internalTimer.eventHandler = handleTimerUpdateEvent
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
                internalTimer.eventHandler = handleTimerUpdateEvent
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
                internalTimer.eventHandler = handleTimerUpdateEvent
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
            internalTimer.eventHandler = handleTimerUpdateEvent
        }

        /// Internal initializer for testing with an injected timer
        init(timer: TimerModel) {
            internalTimer = timer
            internalTimer.eventHandler = handleTimerUpdateEvent
        }

        deinit {
            Log.debug("- { \(self) }")
        }

        /// Permanently stops the timer and releases the event handler.
        public func dispose() {
            internalTimer.dispose()
            eventHandler = nil
        }

        /// Received event from the timer, called on the screen refresh rate
        private func handleTimerUpdateEvent() {
            let avNow = AVAudioTime(hostTime: mach_absolute_time())

            // Find the difference between current time and start time.
            guard let elapsedTime = avNow.timeIntervalSince(otherTime: avStartTime) else {
                return
            }

            currentTime = elapsedTime

            send(event: .time(elapsedTime))
        }

        /// Starts playback, treating `time` as the initial elapsed position.
        ///
        /// - Parameters:
        ///   - time: The initial elapsed time in seconds.
        ///   - hostTime: Optional `mach_absolute_time` anchor; defaults to now.
        public func start(
            at time: TimeInterval,
            hostTime: UInt64? = nil
        ) {
            guard !isRunning else {
                Log.error("Transport is already running")
                return
            }

            let hostTime = hostTime ?? mach_absolute_time()

            let avTime = AVAudioTime(hostTime: hostTime).offset(seconds: -time)
            start(avTime: avTime)
        }

        /// Starts playback anchored to the given `AVAudioTime`.
        public func start(avTime: AVAudioTime) {
            avStartTime = avTime

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

            let avTime = AVAudioTime(hostTime: mach_absolute_time()).offset(seconds: -currentTime)
            avStartTime = avTime

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
