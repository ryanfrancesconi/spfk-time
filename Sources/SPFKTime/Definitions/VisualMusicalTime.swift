import Foundation
import SPFKUtils

/// Information for drawing a musical measure on screen
public struct VisualMusicalTime: Equatable, Codable {
    public static let tempoRange: ClosedRange<Double> = 1 ... 1024
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
            _tempo = newValue?.clamped(to: Self.tempoRange)
            update()
        }
    }

    public var timeSignature: TimeSignature? {
        didSet {
            update()
        }
    }

    public private(set) var visualMeasure: VisualMusicalMeasure?

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
            visualMeasure = nil
            return
        }

        guard let timeSignature else {
            // Log.error("timeSignature must be set to create the visualMeasure")
            visualMeasure = nil
            return
        }

        do {
            visualMeasure = try VisualMusicalMeasure(
                pixelsPerSecond: pixelsPerSecond,
                tempo: tempo,
                timeSignature: timeSignature
            )
        } catch {
            Log.error(error)
        }
    }

    /// How far away in seconds is the next bar relative to currenTime passed in. Useful
    /// for step controls where you want to snap to the next bar. The visualMeasure
    /// must be set or nil is returned.
    ///
    /// - Parameters:
    ///   - currentTime: where the timeline is
    ///   - direction: which direction, rewind or forward
    /// - Returns: The time to the bar
    public func timeToNearestBar(at currentTime: TimeInterval, direction: MovementDirection) -> TimeInterval? {
        guard let visualMeasure else { return nil }

        let timeOfOneBar = visualMeasure.pixelsPerBar / pixelsPerSecond

        var timeTillNextBar = (currentTime / timeOfOneBar).truncatingRemainder(dividingBy: 1)

        if timeTillNextBar == 0 {
            timeTillNextBar = timeOfOneBar
        }

        guard timeTillNextBar != timeOfOneBar else {
            return timeTillNextBar * direction.doubleValue
        }

        var value: Double

        switch direction {
        case .forward:
            value = (1 - timeTillNextBar) * timeOfOneBar

        case .backward:
            value = timeTillNextBar * timeOfOneBar
        }

        return value * direction.doubleValue
    }
}
