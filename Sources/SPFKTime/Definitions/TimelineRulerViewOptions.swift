// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-time

import Foundation

/// Configuration for a timeline ruler header.
public struct TimelineRulerViewOptions: Equatable, Codable, Sendable {
    /// The type of time representation shown in a ruler's time lane.
    public enum DisplayType: String, Equatable, Codable, Sendable {
        /// Wall-clock seconds, elapsed from the start of the file.
        case realTime
        /// SMPTE timecode, offset by the file's start timecode.
        case timecode
        /// The time lane is hidden.
        case none

        public var timeDomain: TimeDomain {
            switch self {
            case .realTime, .none: .realTime
            case .timecode: .timecode
            }
        }
    }

    /// The time representation shown in the ruler's time lane.
    public var timeDisplay: DisplayType = .realTime

    /// Whether the ruler draws musical bars below the time lane.
    public var showsBarNumbers: Bool = true

    /// Whether to draw a horizontal center line through the ruler.
    public var drawCenterLine: Bool = false

    /// Whether to draw horizontal grid lines across the ruler's center area.
    public var drawGrid: Bool = false

    /// The vertical spacing in points between horizontal grid lines.
    public var gridSpacing: CGFloat = 50

    public init(
        timeDisplay: DisplayType = .realTime,
        showsBarNumbers: Bool = true
    ) {
        self.timeDisplay = timeDisplay
        self.showsBarNumbers = showsBarNumbers
    }
}
