// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-time

import Foundation
import SPFKAudioBase
import SPFKBase

/// Combines a tempo and time signature to compute pulse durations and bar rates.
///
/// Pulse durations are cached and recalculated whenever ``tempo`` or ``timeSignature``
/// changes. Use ``duration(pulse:)`` to get the real-time length of any ``MusicalPulse``.
public struct MusicalMeasureDescription: Equatable, Codable, Hashable, Sendable {
    /// The time signature. Changing this recalculates all cached durations.
    public var timeSignature: TimeSignature {
        didSet {
            update()
        }
    }

    /// The tempo in beats per minute. Changing this recalculates all cached durations.
    public var bpm: Bpm {
        didSet {
            update()
        }
    }

    /// The number of bars that fit in one second at the current tempo and time signature.
    public private(set) var barsPerSecond: TimeInterval = 0

    /// Creates a measure description.
    ///
    /// - Parameters:
    ///   - timeSignature: The time signature (defaults to 4/4).
    ///   - bpm: The tempo in BPM (defaults to 60, clamped to the valid range).
    public init(timeSignature: TimeSignature = ._4_4, bpm: Bpm = .bpm60) {
        self.timeSignature = timeSignature
        self.bpm = bpm.clamped(to: Bpm.tempoRange)
        update()
    }

    private mutating func update() {
        durationValues.removeAll()

        // re-cache these
        for pulse in MusicalPulse.allCases {
            durationValues[pulse] = duration(pulse: pulse)
        }

        barsPerSecond = 1 / duration(pulse: .bar)
    }

    private var durationValues = [MusicalPulse: TimeInterval]()

    /// Returns the duration in seconds of the given pulse at the current tempo and time signature.
    public func duration(pulse: MusicalPulse) -> TimeInterval {
        if let value = durationValues[pulse] {
            return value
        }

        var value: TimeInterval

        let quarterNoteDuration = bpm.quarterNoteDuration

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
    /// How far away in seconds is the next bar/beat/subdivision relative to currentTime passed in. Useful
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

        let value: Double = switch direction {
        case .forward:
            (1 - timeTillNextPulse) * timeOfOnePulse

        case .backward:
            timeTillNextPulse * timeOfOnePulse
        }

        return value * direction.doubleValue
    }

    /// Convenience that calculates the distance to the nearest whole second boundary.
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
        MusicalMeasureDescription(timeSignature: \(timeSignature), bpm: \(bpm.stringValue))
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
