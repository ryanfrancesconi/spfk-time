// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-time

import Foundation
import SPFKUtils

/// A musical position expressed as bar, beat, and subdivision values.
///
/// Converts a time-in-seconds into a musical position using the associated
/// ``MusicalMeasureDescription``. All values are 1-based for display
/// (bar 1, beat 1, subdivision 1 = time 0).
public struct MusicalPulseDescription: Hashable, Codable, Sendable {
    /// The measure definition (tempo + time signature) used for conversion.
    public var measure = MusicalMeasureDescription(timeSignature: ._4_4, bpm: .bpm120)

    /// Formatted string for transport display, e.g. `"1 1 1"`.
    public var stringValue: String {
        "\(bar) \(beat) \(subdivision)"
    }

    /// Current bar number (1-based).
    public private(set) var bar: Int = 1

    /// Current beat within the bar (1-based, quarter-note grid).
    public private(set) var beat: Int = 1

    /// Current subdivision within the beat (1-based, sixteenth-note grid).
    public private(set) var subdivision: Int = 1

    /// Fractional bar position (0-based, continuous).
    public private(set) var fractionalBar: Double = 0

    /// Fractional beat within the current bar (0-based, continuous).
    public private(set) var fractionalBeat: Double = 0

    /// Fractional subdivision within the current beat (0-based, continuous).
    public private(set) var fractionalSubdivision: Double = 0

    /// The time value in seconds that produced this position.
    public private(set) var seconds: TimeInterval = 0

    /// Creates a pulse description at the given time.
    public init(time: TimeInterval = 0) {
        update(time: time)
    }

    /// Recalculates bar, beat, and subdivision from a new time value.
    public mutating func update(time: TimeInterval) {
        seconds = time

        guard time >= 0 else {
            fractionalBar = 0
            fractionalBeat = 0
            bar = 0
            beat = 0
            subdivision = 0
            return
        }

        fractionalBar = time * measure.barsPerSecond
        fractionalBeat = fractionalBar.truncatingRemainder(dividingBy: 1) * Double(measure.timeSignature.numerator)
        fractionalSubdivision = fractionalBeat.truncatingRemainder(dividingBy: 1) * 4

        // this rounds down which is what we want for a bar display in the transport
        bar = Int(fractionalBar) + 1
        beat = Int(fractionalBeat) + 1
        subdivision = Int(fractionalSubdivision) + 1

        // Swift.print(debugDescription)
    }
}

extension MusicalPulseDescription: CustomDebugStringConvertible {
    public var debugDescription: String {
        "#expect(MusicalPulseDescription(time: \(seconds)).stringValue == \"\(stringValue)\")"
    }
}
