import Foundation

/// Enum describing a time domain.
public enum TimeDomain: String, CaseIterable {
    case realTime = "Time"
    case timecode = "Timecode"
    case musical = "Bars"
}

