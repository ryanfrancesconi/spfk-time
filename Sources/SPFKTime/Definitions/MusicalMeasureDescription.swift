import Foundation
import SPFKUtils

public struct MusicalMeasureDescription: Equatable, Codable, Hashable, Sendable {
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

    public private(set) var barsPerSecond: TimeInterval = 0

    public init(timeSignature: TimeSignature = ._4_4, tempo: Double) {
        self.timeSignature = timeSignature
        self.tempo = tempo.clamped(to: Self.tempoRange)
        update()
    }

    private mutating func update() {
        durationValues.removeAll()

        // recache these
        for pulse in MusicalPulse.allCases {
            durationValues[pulse] = duration(pulse: pulse)
        }

        barsPerSecond = 1 / duration(pulse: .bar)
    }

    private var durationValues = [MusicalPulse: TimeInterval]()

    public func duration(pulse: MusicalPulse) -> TimeInterval {
        if let value = durationValues[pulse] {
            return value
        }

        var value: TimeInterval

        let quarterNoteDuration = 60 / tempo

        switch pulse {
        case .bar:
            let quartersPerPulse = 4 / timeSignature.denominator.double
            value = quarterNoteDuration * timeSignature.numerator.double * quartersPerPulse

        case .quarter:
            value = quarterNoteDuration

        case .eighth:
            value = quarterNoteDuration / 2

        case .sixteenth:
            value = quarterNoteDuration / 4
        }

        return value
    }
}

extension MusicalMeasureDescription {
    /// How far away in seconds is the next bar/beat/subdivision relative to currenTime passed in. Useful
    /// for step controls where you want to snap to the next pulse type. The visualMeasure
    /// must be set or nil is returned.
    ///
    /// - Parameters:
    ///   - currentTime: where the timeline is
    ///   - direction: which direction, rewind or forward
    /// - Returns: The time to the pulse
    public static func timeToNearest(
        pulse: MusicalPulse?,
        measure: MusicalMeasureDescription?,
        at currentTime: TimeInterval,
        direction: MovementDirection
    ) -> TimeInterval {
        var timeOfOnePulse: TimeInterval = 1

        if let pulse, let measure {
            timeOfOnePulse = measure.duration(pulse: pulse)
        }

        var timeTillNextPulse = (currentTime / timeOfOnePulse).truncatingRemainder(dividingBy: 1)

        let nearOne = timeTillNextPulse.isApproximatelyEqual(to: 1, absoluteTolerance: 0.0001)
        let nearZero = timeTillNextPulse.isApproximatelyEqual(to: 0, absoluteTolerance: 0.001)

        if nearZero || nearOne {
            timeTillNextPulse = timeOfOnePulse
        }

        guard timeTillNextPulse != timeOfOnePulse else {
            return timeTillNextPulse * direction.doubleValue
        }

        var value: Double

        switch direction {
        case .forward:
            value = (1 - timeTillNextPulse) * timeOfOnePulse

        case .backward:
            value = timeTillNextPulse * timeOfOnePulse
        }

        return value * direction.doubleValue
    }

    public static func timeToNearestSecond(
        at currentTime: TimeInterval,
        direction: MovementDirection
    ) -> TimeInterval? {
        timeToNearest(pulse: nil, measure: nil, at: currentTime, direction: direction)
    }
}

extension MusicalMeasureDescription: CustomStringConvertible {
    public var description: String {
        """
        MusicalMeasureDescription(timeSignature: \(timeSignature), tempo: \(tempo))
        """
    }
}

extension MusicalMeasureDescription: CustomDebugStringConvertible {
    var testValue: String {
        "quarterNoteDuration: \(duration(pulse: .quarter)), barsPerSecond: \(barsPerSecond)"
    }

    public var debugDescription: String {
        """
        #expect(\(description).testValue == \"\(testValue)\")
        """
    }
}
