import AppKit
import Foundation

/// Identifies an UI object as having a concept of musical time vs pixels on screen, such as
/// a timeline or audio drawn
public protocol TimelineDrawable {
    var visualTime: VisualMusicalTime { get set }
}

// MARK: - Conveniences

extension TimelineDrawable {
    public var pixelsPerSecond: Double {
        get { visualTime.pixelsPerSecond }
        set { visualTime.pixelsPerSecond = newValue }
    }

    public var visualMeasure: VisualMusicalPulse? {
        visualTime.visualPulse
    }
}

extension TimelineDrawable where Self: NSView {
    public func eventToTime(_ event: NSEvent) -> TimeInterval {
        var svLocation = convert(event.locationInWindow, from: nil)
        svLocation.x = max(0, svLocation.x)

        return TimeInterval(svLocation.x) / pixelsPerSecond
    }
}
