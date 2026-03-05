import Foundation

/// The three supported time domains for display and navigation.
///
/// Each case carries a raw string suitable for use as a UI label.
public enum TimeDomain: String, CaseIterable {
    /// Wall-clock seconds (e.g. `"0:03.500"`).
    case realTime = "Time"

    /// SMPTE timecode (e.g. `"01:00:00:00"`).
    case timecode = "Timecode"

    /// Musical bars and beats (e.g. `"1 1 1"`).
    case musical = "Bars"
}

