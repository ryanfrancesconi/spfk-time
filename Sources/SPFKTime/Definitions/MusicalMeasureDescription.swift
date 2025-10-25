import Foundation

public struct MusicalMeasureDescription: Equatable, Codable, Hashable {
    public static let tempoRange: ClosedRange<Double> = 1 ... 1024

    public var timeSignature: TimeSignature {
        didSet {
            update()
        }
    }

    public var tempo: Double {
        didSet {
            update()
        }
    }

    public private(set) var quarterNoteDuration: TimeInterval = 0

    public private(set) var barsPerSecond: TimeInterval = 0
    public private(set) var quarterNotesPerSecond: TimeInterval = 0
    public private(set) var sixteenthNotesPerSecond: TimeInterval = 0

    public init(timeSignature: TimeSignature = ._4_4, tempo: Double) {
        self.timeSignature = timeSignature
        self.tempo = tempo.clamped(to: Self.tempoRange)
        update()
    }

    private mutating func update() {
        quarterNoteDuration = 60 / tempo
        quarterNotesPerSecond = 1 / quarterNoteDuration
        sixteenthNotesPerSecond = quarterNotesPerSecond / 4
        barsPerSecond = 1 / duration(pulse: .bar)
    }

    public func duration(pulse: MusicalPulse) -> TimeInterval {
        switch pulse {
        case .bar:
            let quartersPerPulse = 4 / timeSignature.denominator.double
            return quarterNoteDuration * timeSignature.numerator.double * quartersPerPulse

        case .quarter:
            return quarterNoteDuration
            
        case .eighth:
            return quarterNoteDuration / 2

        case .sixteenth:
            return quarterNoteDuration / 4
        }
    }
}

extension MusicalMeasureDescription: CustomDebugStringConvertible {
    var testValue: String {
        "quarterNoteDuration: \(quarterNoteDuration), barsPerSecond: \(barsPerSecond), quarterNotesPerSecond: \(quarterNotesPerSecond), sixteenthNotesPerSecond: \(sixteenthNotesPerSecond)"
    }

    public var debugDescription: String {
        """
        #expect(MusicalMeasureDescription(timeSignature: \(timeSignature), tempo: \(tempo)).testValue == \"\(testValue)\")
        """
    }
}
