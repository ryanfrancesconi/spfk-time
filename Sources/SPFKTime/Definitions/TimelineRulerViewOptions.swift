// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-time

import Foundation

/// Configuration for a dual-ruler timeline header.
public struct TimelineRulerViewOptions: Equatable {
    /// The type of time representation shown in a ruler lane.
    public enum DisplayType: Equatable {
        /// Wall-clock seconds.
        case realTime
        /// SMPTE timecode.
        case timecode
        /// Musical bars and beats.
        case musical
        /// Ruler lane is hidden.
        case none
    }

    /// The time domain shown in the top ruler lane.
    public var topRuler: DisplayType = .realTime

    /// The time domain shown in the bottom ruler lane.
    public var bottomRuler: DisplayType = .musical

    /// Whether to draw a horizontal center line through the ruler.
    public var drawCenterLine: Bool = false

    /// Whether to draw vertical grid lines.
    public var drawGrid: Bool = false

    /// The spacing in points between vertical grid lines.
    public var gridSpacing: CGFloat = 50

    public init(
        topRuler: DisplayType = .realTime,
        bottomRuler: DisplayType = .musical
    ) {
        self.topRuler = topRuler
        self.bottomRuler = bottomRuler
    }
}
