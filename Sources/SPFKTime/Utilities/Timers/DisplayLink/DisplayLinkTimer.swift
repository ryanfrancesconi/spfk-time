import AppKit
import Foundation
import QuartzCore
import SPFKUtils

@available(macOS 14, *)
@MainActor
public class DisplayLinkTimer: @preconcurrency TimerModel {
    public var eventHandler: (() -> Void)?

    public var timeInterval: TimeInterval {
        displayLink?.duration ?? 0
    }

    public private(set) var state: TimerState = .suspended

    public var fps: Double {
        guard let displayLink else { return 0 }
        return 1 / (displayLink.targetTimestamp - displayLink.timestamp)
    }

    public var timestamp: CFTimeInterval {
        displayLink?.timestamp ?? 0
    }

    private var displayLink: CADisplayLink?

    public init(on view: NSView) {
        displayLink = view.displayLink(target: self, selector: #selector(handleUpdate))
    }

    public init(window: NSWindow) {
        displayLink = window.displayLink(target: self, selector: #selector(handleUpdate))
    }

    public init(screen: NSScreen) {
        displayLink = screen.displayLink(target: self, selector: #selector(handleUpdate))
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
        Log.debug("* { DisplayLinkTimer }")
    }
}
