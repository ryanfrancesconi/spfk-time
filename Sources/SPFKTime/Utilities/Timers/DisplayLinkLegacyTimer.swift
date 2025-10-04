import Foundation
import SPFKUtils

/// Legacy Timer based on screen refresh rate
@available(macOS, deprecated: 14.0, message: "Use DisplayLinkTimer2")
public class DisplayLinkLegacyTimer: TimerModel {
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

    public init(onQueue queue: DispatchQueue = .global(qos: .default)) {
        do {
            Log.debug("Creating on", queue)
            displayLink = try DisplayLink(onQueue: queue)
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
        Log.debug("* { DisplayLinkLegacyTimer }")
    }

    public func dispose() {
        displayLink?.cancel()
        eventHandler = nil
        displayLink = nil
    }
}
