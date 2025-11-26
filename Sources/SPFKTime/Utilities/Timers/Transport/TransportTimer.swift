import AppKit
import AVFoundation
import SwiftExtensions
import SPFKUtils
import TimecodeKit

public class TransportTimer {
    public var eventHandler: ((TransportTimerEvent) -> Void)?

    public private(set) var isPaused: Bool = false

    /// The current position of the playhead in fractional seconds
    /// This is  real time seconds. Can only be set when the timer isn't running.
    public var currentTime: TimeInterval = 0

    private var resumeTask: Task<Void, Error>?

    private var avStartTime = AVAudioTime.now()

    private var lastStoredHostTime: UInt64 = 0

    private let internalTimer: TimerModel

    // MARK: - Init

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

    deinit {
        Log.debug("* { TransportTimer }")
    }

    public func dispose() {
        internalTimer.dispose()
        eventHandler = nil
    }

    /// Received event from the timer, called on the screen refresh rate
    @objc
    private func handleTimerUpdateEvent() {
        let avNow = AVAudioTime(hostTime: mach_absolute_time()) // + Self.hostTimeShim)

        // Find the difference between current time and start time.
        guard let elapsedTime = avNow.timeIntervalSince(otherTime: avStartTime) else {
            return
        }

        self.currentTime = elapsedTime

        send(event: .time(elapsedTime))
    }

    public func start(
        at time: TimeInterval,
        hostTime: UInt64? = nil
    ) {
        guard !isRunning else {
            Log.error("Transport is already running")
            return
        }

        let hostTime = hostTime ?? mach_absolute_time()

        let avTime = AVAudioTime(hostTime: hostTime).offset(seconds: -time) // + Self.futureShim)
        start(avTime: avTime)
    }

    public func start(avTime: AVAudioTime) {
        self.avStartTime = avTime
        lastStoredHostTime = avTime.hostTime

        internalTimer.resume()
        send(event: .state(.start))
    }

    public func stop() {
        guard isRunning else { return }

        internalTimer.suspend()
        send(event: .state(.stop))
    }

    public func pause() {
        guard isRunning else { return }
        stop()
        isPaused = true
        send(event: .state(.pause))
    }

    public func resume() {
        guard isPaused else { return }
        isPaused = false
        self.start(at: currentTime)
        send(event: .state(.resume))
    }
}

extension TransportTimer {
    public var isRunning: Bool {
        internalTimer.state == .resumed
    }

    public var fps: Double {
        internalTimer.fps
    }

    fileprivate func send(event: TransportTimerEvent) {
        self.eventHandler?(event)
    }
}
