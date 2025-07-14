import SPFKUtils
import Foundation

// Timer based on screen refresh rate
public class DisplayLinkTimer: TimerModel {
    public var timeInterval: TimeInterval {
        displayLink?.timeInterval ?? 0
    }

    public var eventHandler: (() -> Void)? {
        didSet {
            displayLink?.callback = eventHandler
        }
    }

    public private(set) var state: TimerFactory.State = .suspended

    private var displayLink: DisplayLink?

    public init() {
        do {
            displayLink = try DisplayLink()
        } catch {
            Log.error(error)
        }
    }

    public func resume() {
        guard state == .suspended else { return }
        displayLink?.start()
        state = .resumed
    }

    public func suspend() {
        guard state == .resumed else { return }
        displayLink?.suspend()
        state = .suspended
    }

    deinit {
        Log.debug("* { DisplayLinkTimer }")

        eventHandler = nil
        displayLink = nil
    }
}
