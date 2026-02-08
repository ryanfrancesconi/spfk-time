import Foundation
import Numerics
import SPFKAudioBase
import SPFKUtils

/// Information for drawing a musical measure on screen
public struct VisualMusicalTime: Equatable, Codable, Sendable {
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

    private var _tempo: Bpm?

    /// This will be clamped to a valid range
    public var tempo: Bpm? {
        get { _tempo }
        set {
            _tempo = newValue?.clamped(to: Bpm.tempoRange)
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
        tempo: Bpm? = nil,
        timeSignature: TimeSignature? = nil
    ) {
        self.pixelsPerSecond = pixelsPerSecond
        self.timeSignature = timeSignature
        self.tempo = tempo

        update()
    }

    private mutating func update() {
        guard let tempo else {
            visualPulse = nil
            return
        }

        guard let timeSignature else {
            visualPulse = nil
            return
        }

        // We need a tempo and a signature to create a VisualMusicalPulse

        do {
            visualPulse = try VisualMusicalPulse(
                pixelsPerSecond: pixelsPerSecond,
                measure: MusicalMeasureDescription(
                    timeSignature: timeSignature,
                    tempo: tempo
                )
            )

        } catch {
            Log.error(error)
        }
    }
}

extension VisualMusicalTime: CustomDebugStringConvertible {
    public var debugDescription: String {
        """
        VisualMusicalTime(pixelsPerSecond: \(pixelsPerSecond), tempo: \(tempo?.stringValue ?? "nil"), timeSignature: \(timeSignature?.debugDescription ?? "nil"))
        """
    }
}
