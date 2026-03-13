// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-time

import Foundation
import Numerics
import SPFKBase
import SPFKAudioBase
import SPFKUtils

/// Combines zoom level, tempo, and time signature to produce a ``VisualMusicalPulse``
/// for drawing musical grids on screen.
///
/// When any input changes, the ``visualPulse`` is recomputed. Both ``tempo`` and
/// ``timeSignature`` must be non-nil for a valid pulse to be produced.
public struct VisualMusicalTime: Equatable, Codable, Sendable {
    /// Default tempo used when none is specified (120 BPM).
    public static let defaultTempo: Double = 120

    public static func == (lhs: VisualMusicalTime, rhs: VisualMusicalTime) -> Bool {
        lhs.pixelsPerSecond == rhs.pixelsPerSecond &&
            lhs.bpm == rhs.bpm &&
            lhs.timeSignature == rhs.timeSignature
    }

    private var _pixelsPerSecond: Double = 30 // arbitrary default

    /// The zoom level in pixels per second. Must be positive, finite, and non-NaN.
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

    private var _bpm: Bpm?

    /// The tempo in BPM, clamped to a valid range. Set to `nil` to disable musical grid.
    public var bpm: Bpm? {
        get { _bpm }
        set {
            _bpm = newValue?.clamped(to: Bpm.tempoRange)
            update()
        }
    }

    /// The time signature. Set to `nil` to disable musical grid.
    public var timeSignature: TimeSignature? {
        didSet {
            update()
        }
    }

    /// The computed pulse layout, or `nil` if tempo or time signature is missing.
    public private(set) var visualPulse: VisualMusicalPulse?

    public init(
        pixelsPerSecond: Double = 30,
        bpm: Bpm? = nil,
        timeSignature: TimeSignature? = nil
    ) {
        self.pixelsPerSecond = pixelsPerSecond
        self.timeSignature = timeSignature
        self.bpm = bpm

        update()
    }

    private mutating func update() {
        guard let bpm else {
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
                    bpm: bpm
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
        VisualMusicalTime(pixelsPerSecond: \(pixelsPerSecond), bpm: \(bpm?.stringValue ?? "nil"), timeSignature: \(timeSignature?.debugDescription ?? "nil"))
        """
    }
}
