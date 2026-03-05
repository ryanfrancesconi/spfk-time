// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-time

import Foundation

/// A UI element that maps between pixel coordinates and musical/real time.
///
/// Conforming views (e.g. timeline rulers, waveform displays) use ``visualTime``
/// to convert between screen positions and time values.
@MainActor public protocol TimelineDrawable {
    /// The visual time configuration driving pixel ↔ time conversions.
    var visualTime: VisualMusicalTime { get set }
}

// MARK: - Conveniences

extension TimelineDrawable {
    /// Shorthand for `visualTime.pixelsPerSecond`.
    public var pixelsPerSecond: Double {
        get { visualTime.pixelsPerSecond }
        set { visualTime.pixelsPerSecond = newValue }
    }

    /// Shorthand for `visualTime.visualPulse`.
    public var visualMeasure: VisualMusicalPulse? {
        visualTime.visualPulse
    }
}

extension TimelineDrawable {
    /// Converts a rectangle to a closed time range based on the current zoom level.
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

#if canImport(AppKit) && !targetEnvironment(macCatalyst)

    import AppKit

    @MainActor
    extension TimelineDrawable where Self: NSView {
        /// The time span visible across the view's width.
        public var visualDuration: TimeInterval {
            TimeInterval(frame.width) / visualTime.pixelsPerSecond
        }

        /// Converts a mouse event's x-position to a time value in seconds.
        public func eventToTime(_ event: NSEvent) -> TimeInterval {
            var svLocation = convert(event.locationInWindow, from: nil)
            svLocation.x = max(0, svLocation.x)
            return TimeInterval(svLocation.x) / pixelsPerSecond
        }
    }
#endif
