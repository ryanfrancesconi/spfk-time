// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-time

import Foundation

/// Selects how a time value is rendered as a display string.
public enum TimeDisplayFormat: String, Codable, CaseIterable {
    /// SMPTE timecode format (e.g. `"01:00:00:00"`).
    case timecode

    /// Fractional seconds (e.g. `"3.500"`).
    case seconds

    /// Creates a format from its UI title, or returns `nil` if the title is unrecognized.
    public init?(title: String) {
        for item in Self.allCases where item.title == title {
            self = item
            return
        }

        return nil
    }

    /// A human-readable title for this format.
    public var title: String {
        switch self {
        case .timecode:
            return "Timecode"

        case .seconds:
            return "Seconds"
        }
    }
}
