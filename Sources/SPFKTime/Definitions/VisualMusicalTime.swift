import Foundation
import SPFKUtils

/// Information for drawing a musical measure on screen
public struct VisualMusicalTime: Equatable, Codable {
    public static let tempoRange: ClosedRange<Double> = 1 ... 1024
    public static let defaultBpm: Double = 120

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

    public var timeSignature: TimeSignature = ._4_4 {
        didSet {
            update()
        }
    }

    public private(set) var visualMeasure: VisualMusicalMeasure?

    public init(pixelsPerSecond: Double = 30, tempo: Double? = nil, timeSignature: TimeSignature = ._4_4) {
        self.timeSignature = timeSignature
        self.pixelsPerSecond = pixelsPerSecond
        self.tempo = tempo

        update()
    }

    private mutating func update() {
        guard let tempo, tempo > 0 else {
            Log.error("tempo must be set to create the visualMeasure")
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
}
