// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-time

import Foundation

/// Configuration for a dual-ruler timeline header.
public struct TimelineRulerViewOptions: Equatable, Codable, Sendable {
    /// The type of time representation shown in a ruler lane.
    public enum DisplayType: Equatable, Codable, Sendable {
        /// Wall-clock seconds.
        case realTime
        /// SMPTE timecode.
        case timecode
        /// Musical bars and beats.
        case musical
        /// Ruler lane is hidden.
        case none

        public var timeDomain: TimeDomain {
            switch self {
            case .realTime, .none: .realTime
            case .timecode: .timecode
            case .musical: .musical
            }
        }
    }

    /// The time domain shown in the top ruler lane.
    public var topRuler: DisplayType = .realTime

    /// The time domain shown in the bottom ruler lane.
    public var bottomRuler: DisplayType = .musical

    /// Whether to draw a horizontal center line through the ruler.
    public var drawCenterLine: Bool = false

    /// Whether to draw horizontal grid lines across the ruler's center area.
    public var drawGrid: Bool = false

    /// The vertical spacing in points between horizontal grid lines.
    public var gridSpacing: CGFloat = 50

    public init(
        topRuler: DisplayType = .realTime,
        bottomRuler: DisplayType = .musical
    ) {
        self.topRuler = topRuler
        self.bottomRuler = bottomRuler
    }
}
