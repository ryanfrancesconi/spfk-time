import Foundation
import Numerics
import SPFKUtils

/// Information for drawing a musical measure on screen
public struct VisualMusicalTime: Equatable, Codable {
    public static let defaultTempo: Double = 120

    public static func == (lhs: VisualMusicalTime, rhs: VisualMusicalTime) -> Bool {
        lhs.pixelsPerSecond == rhs.pixelsPerSecond &&
            lhs.tempo == rhs.tempo &&
            lhs.timeSignature == rhs.timeSignature
    }

    private var _pixelsPerSecond: Double = 30 // arbitrary default

    public var pixelsPerSecond: Double {
        get { _pixelsPerSecond }
        set {
            guard newValue > 0, !newValue.isNaN, !newValue.isInfinite else {
                return
            }

            _pixelsPerSecond = newValue
            update()
        }
    }

    private var _tempo: Double?

    /// This will be clamped to a valid range
    public var tempo: Double? {
        get { _tempo }
        set {
            _tempo = newValue?.clamped(to: MusicalMeasureDescription.tempoRange)
            update()
        }
    }

    public var timeSignature: TimeSignature? {
        didSet {
            update()
        }
    }

    public private(set) var visualPulse: VisualMusicalPulse?

    public init(
        pixelsPerSecond: Double = 30,

        tempo: Double? = nil,
        timeSignature: TimeSignature? = nil
    ) {
        self.pixelsPerSecond = pixelsPerSecond

        self.timeSignature = timeSignature
        self.tempo = tempo

        update()
    }

    private mutating func update() {
        guard let tempo, tempo > 0 else {
            // Log.error("tempo must be set to create the visualMeasure")
            visualPulse = nil
            return
        }

        guard let timeSignature else {
            // Log.error("timeSignature must be set to create the visualMeasure")
            visualPulse = nil
            return
        }

        do {
            visualPulse = try VisualMusicalPulse(
                pixelsPerSecond: pixelsPerSecond,
                measure: MusicalMeasureDescription(timeSignature: timeSignature, tempo: tempo)
            )

        } catch {
            Log.error(error)
        }
    }

    /// How far away in seconds is the next bar/beat/subdivision relative to currenTime passed in. Useful
    /// for step controls where you want to snap to the next pulse type. The visualMeasure
    /// must be set or nil is returned.
    ///
    /// - Parameters:
    ///   - currentTime: where the timeline is
    ///   - direction: which direction, rewind or forward
    /// - Returns: The time to the pulse
    public func timeToNearest(
        pulse: MusicalPulse?,
        at currentTime: TimeInterval,
        direction: MovementDirection
    ) -> TimeInterval {
        var timeOfOnePulse: TimeInterval = 1

        if let pulse, let visualPulse {
            timeOfOnePulse = visualPulse.measure.duration(pulse: pulse)
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

    public func timeToNearestSecond(
        at currentTime: TimeInterval,
        direction: MovementDirection
    ) -> TimeInterval? {
        timeToNearest(pulse: nil, at: currentTime, direction: direction)
    }
}

extension VisualMusicalTime: CustomDebugStringConvertible {
    public var debugDescription: String {
        """
        VisualMusicalTime(pixelsPerSecond: \(pixelsPerSecond), tempo: \(tempo?.string ?? "nil"), timeSignature: \(timeSignature?.debugDescription ?? "nil"))
        """
    }
}
