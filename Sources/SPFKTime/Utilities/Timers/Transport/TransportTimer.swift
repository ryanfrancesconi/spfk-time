import AppKit
import AVFoundation
import OTCore
import SPFKUtils
import TimecodeKit

public class TransportTimer {
    // HACK, 10 hours in the future to prevent underflow on freshly restarted macs who play deep into a timeline
    private static let futureShim: TimeInterval = 3600 * 10
    private static let hostTimeShim: UInt64 = futureShim.convertedToHostTime()

    // MARK: - Stored Properties

    public var eventHandler: ((TransportTimerEvent) -> Void)?

    public private(set) var isPaused: Bool = false

    /// The current position of the playhead in fractional seconds
    /// This is a real time value. Can only be set when the timer isn't running.
    public var position: TimeInterval = 0

    private var internalTimer: TimerModel
    private var resumeTask: Task<Void, Error>?
    private var startTime = AVAudioTime.now()
    private var lastStoredHostTime: UInt64 = 0

    // MARK: - Init

    public init(on view: NSView) {
        defer {
            internalTimer.eventHandler = updateTime
        }

        if #available(macOS 14, *) {
            internalTimer = DisplayLinkTimer(on: view)
            return
        }

        internalTimer = LegacyDisplayLinkTimer(onQueue: .main)
    }

    public init(on window: NSWindow) {
        defer {
            internalTimer.eventHandler = updateTime
        }

        if #available(macOS 14, *) {
            internalTimer = DisplayLinkTimer(window: window)
            return
        }

        internalTimer = LegacyDisplayLinkTimer(onQueue: .main)
    }

    public init(screen: NSScreen? = NSScreen.screens.first) throws {
        guard let screen else {
            throw NSError(description: "Failed to get NSScreen for display link")
        }

        defer {
            internalTimer.eventHandler = updateTime
        }

        if #available(macOS 14, *) {
            internalTimer = DisplayLinkTimer(screen: screen)
            return
        }

        internalTimer = LegacyDisplayLinkTimer(onQueue: .main)
    }

    deinit {
        Log.debug("* { TransportTimer }")
    }

    public func dispose() {
        internalTimer.dispose()
        eventHandler = nil
    }

    /// Received events from the timer on its queue (utility)
    @objc
    public func updateTime() {
        let currentTime = AVAudioTime(hostTime: mach_absolute_time() + Self.hostTimeShim)

        // Find the difference between current time and start time.
        guard let elapsedTime = currentTime.timeIntervalSince(otherTime: startTime) else {
            return
        }

        position = elapsedTime

        send(event:
            .time(elapsedTime)
        )
    }

    public func start(
        at time: TimeInterval? = nil,
        hostTime: UInt64? = nil
    ) {
        guard !isRunning else {
            Log.error("Transport is already playing")
            return
        }

        let time = time ?? position
        let hostTime = hostTime ?? mach_absolute_time()

        lastStoredHostTime = hostTime

        startTime = AVAudioTime(hostTime: hostTime).offset(seconds: -time + Self.futureShim)

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

    public func resume(withTimeInterval: TimeInterval = 0.1) {
        guard isPaused else { return }

        guard withTimeInterval > 0 else {
            isPaused = false
            send(event: .state(.resume))
            return
        }

        let withTimeInterval = max(0.1, withTimeInterval)

        resumeTask?.cancel()
        resumeTask = Task<Void, Error> {
            try await Task.sleep(seconds: withTimeInterval)
            try Task.checkCancellation()

            Task { @MainActor in
                self.isPaused = false
                self.start()
                self.send(event: .state(.resume))
            }
        }
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
