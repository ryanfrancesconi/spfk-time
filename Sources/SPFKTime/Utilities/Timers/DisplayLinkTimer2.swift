import AppKit
import Foundation
import SPFKUtils

@available(macOS 14, *)
public class DisplayLinkTimer2: TimerModel {
    public var timeInterval: TimeInterval {
        displayLink?.duration ?? 0
    }

    public var fps: Double {
        guard let displayLink else { return 0 }
        return 1 / (displayLink.targetTimestamp - displayLink.timestamp)
    }

    public var timestamp: CFTimeInterval {
        displayLink?.timestamp ?? 0
    }

    public var eventHandler: (() -> Void)?

    public private(set) var state: TimerFactory.State = .suspended

    private var displayLink: CADisplayLink?

    public private(set) var elapsed: CFTimeInterval = 0

    public init(on view: NSView, eventHandler: (() -> Void)? = nil) {
        displayLink = view.displayLink(target: self, selector: #selector(handleUpdate))
        self.eventHandler = eventHandler
    }

    @objc private func handleUpdate(_ sender: CADisplayLink) {
        eventHandler?()
    }

    public func resume() {
        guard let displayLink else { return }

        guard state == .suspended else { return }

        displayLink.isPaused = false
        displayLink.add(to: .main, forMode: .common)

        state = .resumed
    }

    public func suspend() {
        guard let displayLink else { return }

        guard state == .resumed else { return }

        elapsed = 0
        displayLink.isPaused = true
        displayLink.remove(from: .main, forMode: .common)

        state = .suspended
    }

    public func dispose() {
        displayLink?.invalidate()
        displayLink = nil
        eventHandler = nil
    }

    deinit {
        Log.debug("* { DisplayLinkTimer2 }")
    }
}
