import AppKit
import AVFoundation
import OTCore
import SPFKUtils
import TimecodeKit

public class TransportTimer {
    public enum Event {
        case state(PlayState)
        case time(TimeInterval)

//        case willEnd
//        case ended
    }

    public enum PlayState {
        case start
        case stop
        case pause
        case resume
    }

    public var eventHandler: ((Event) -> Void)?

    // MARK: - Stored Properties

    private var mainTimer: TimerModel

    private var pauseTimer: Timer?

    private var startTime = AVAudioTime.now()

    private var lastStoredHostTime: UInt64 = 0

    public private(set) var isPaused: Bool = false

    // HACK, 10 hours in the future to prevent underflow on freshly restarted macs who play deep into a timeline
    private static let futureShim: TimeInterval = 3600 * 10
    private static let hostTimeShim: UInt64 = futureShim.convertedToHostTime()

    /// The current position of the playhead in fractional seconds
    /// This is a real time value. Can only be set when the timer isn't running.
    public var position: TimeInterval = 0

    public var duration: TimeInterval?

    public var isRunning: Bool {
        mainTimer.state == .resumed
    }

    public var timeInterval: TimeInterval {
        mainTimer.timeInterval
    }

    public var fps: Double {
        1 / timeInterval
    }

    // MARK: - Init

    public init(on view: NSView) {
        if #available(macOS 14, *) {
            mainTimer = DisplayLinkTimer2(on: view)
            mainTimer.eventHandler = updateTime

        } else {
            mainTimer = DisplayLinkLegacyTimer(onQueue: .main)
            mainTimer.eventHandler = updateTime
        }
    }

    deinit {
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

        eventHandler?(
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
        mainTimer.resume()
        eventHandler?(.state(.start))
    }

    public func stop() {
        guard isRunning else { return }

        mainTimer.suspend()
        eventHandler?(.state(.stop))
    }

    public func pause() {
        guard isRunning else { return }
        stop()
        isPaused = true
        eventHandler?(.state(.pause))
    }

    public func resume(withTimeInterval: TimeInterval = 0.1) {
        guard isPaused else { return }

        guard withTimeInterval > 0 else {
            isPaused = false
            eventHandler?(.state(.resume))
            return
        }

        let withTimeInterval = max(0.1, withTimeInterval)

        pauseTimer?.invalidate()
        pauseTimer = Timer.scheduledTimer(
            withTimeInterval: withTimeInterval,
            repeats: false,
            block: { [weak self] _ in
                guard let self else { return }

                Task { @MainActor in
                    self.isPaused = false
                    self.start()
                    self.eventHandler?(.state(.resume))
                }
            }
        )
    }
}
