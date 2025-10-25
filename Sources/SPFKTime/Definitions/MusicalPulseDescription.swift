import Foundation
import SPFKUtils

public struct MusicalPulseDescription: Equatable, Hashable, Codable {
    public var measure = MusicalMeasureDescription(timeSignature: ._4_4, tempo: 120)

    /// used in transport display
    public var stringValue: String {
        "\(bar) \(beat) \(subdivision)"
    }

    public private(set) var bar: Int = 1
    public private(set) var beat: Int = 1 // quarter note
    public private(set) var subdivision: Int = 1 // sixteenth note

    public private(set) var fractionalBar: Double = 0
    public private(set) var fractionalBeat: Double = 0
    public private(set) var fractionalSubdivision: Double = 0

    public private(set) var seconds: TimeInterval = 0

    public init(time: TimeInterval = 0) {
        update(time: time)
    }

    public mutating func update(time: TimeInterval) {
        self.seconds = time

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
        fractionalSubdivision = fractionalBeat.truncatingRemainder(dividingBy: 1) * MusicalMeasureDescription.subdivisionsPerBeat

        // this rounds down which is what we want for a bar display in the transport
        bar = Int(fractionalBar) + 1
        beat = Int(fractionalBeat) + 1
        subdivision = Int(fractionalSubdivision) + 1

        Swift.print(debugDescription)
    }
}

extension MusicalPulseDescription: CustomDebugStringConvertible {
    public var debugDescription: String {
        "#expect(MusicalPulseDescription(time: \(seconds)).stringValue == \"\(stringValue)\")"
    }
}

public enum MusicalPulse: Equatable, Codable, Hashable {
    case bar
    case beat // quarter note
    case subdivision // sixteenth note
}
