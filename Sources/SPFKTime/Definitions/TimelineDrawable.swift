import AppKit
import Foundation

/// Identifies an UI object as having a concept of musical time vs pixels on screen, such as
/// a timeline or audio drawn
@MainActor public protocol TimelineDrawable {
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

@MainActor
extension TimelineDrawable where Self: NSView {
    public var visualDuration: TimeInterval {
        TimeInterval(frame.width) / visualTime.pixelsPerSecond
    }

    public func eventToTime(_ event: NSEvent) -> TimeInterval {
        var svLocation = convert(event.locationInWindow, from: nil)
        svLocation.x = max(0, svLocation.x)
        return TimeInterval(svLocation.x) / pixelsPerSecond
    }
}

extension TimelineDrawable {
    public func rectToTimeRange(_ rect: CGRect) throws -> ClosedRange<TimeInterval> {
        guard rect.width > 0 else {
            throw NSError(description: "Invalid rect \(rect)")
        }

        let x = rect.origin.x.double
        let maxX = x + rect.width.double
        let pixelsPerSecond = pixelsPerSecond

        let startTime = x / pixelsPerSecond
        let endTime = maxX / pixelsPerSecond

        return startTime ... endTime
    }
}
