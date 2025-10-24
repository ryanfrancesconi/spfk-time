import Foundation

public struct MusicalPulse {
    static let subdivisionsPerBeat: Double = 4

    public var tempo: Double = 120 {
        didSet {
            barsPerSecond = beatsInSecond / Double(timeSignature.numerator)
        }
    }

    public var beatsInSecond: Double { tempo / 60 }

    public var timeSignature: TimeSignature = ._4_4

    /// used in transport display
    public var stringValue: String {
        String(bar) + " " + String(beat) + " " + String(subdivision)
    }

    public private(set) var barsPerSecond: Double = 0.5

    public private(set) var bar: Int = 1
    public private(set) var beat: Int = 1
    public private(set) var subdivision: Int = 1
    public private(set) var fractionalBar: Double = 0
    public private(set) var fractionalBeat: Double = 0

    public init(time: TimeInterval = 0) {
        updateFrom(time: time)
    }

    public mutating func updateFrom(time: TimeInterval) {
        guard time >= 0 else {
            fractionalBar = 0
            fractionalBeat = 0
            bar = 0
            beat = 0
            subdivision = 0
            return
        }

        fractionalBar = time * barsPerSecond

        // this rounds down which is what we want for the bar display in the transport
        bar = Int(fractionalBar) + 1
        beat = Int(fractionalBeat) + 1

        fractionalBeat = fractionalBar.truncatingRemainder(dividingBy: 1) * Double(timeSignature.numerator)
        subdivision = Int(fractionalBeat.truncatingRemainder(dividingBy: 1) * Self.subdivisionsPerBeat) + 1
    }
}
