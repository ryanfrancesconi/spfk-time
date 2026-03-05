// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-time

import Foundation
import SPFKUtils

/// Converts musical pulse durations into pixel widths at a given zoom level.
///
/// Precomputes pixel widths for bar, quarter, eighth, and sixteenth note durations
/// from the associated ``MusicalMeasureDescription`` and `pixelsPerSecond` scale factor.
public struct VisualMusicalPulse: Equatable, Codable, Sendable {
    /// The measure definition (tempo + time signature) used for duration calculations.
    public private(set) var measure: MusicalMeasureDescription

    /// The current zoom level expressed as pixels per second of real time.
    public private(set) var pixelsPerSecond: Double

    /// How wide a 1/16 note is in pixels
    private var pixelsPerSubdivision: CGFloat

    private var pixelsPerEighth: CGFloat

    /// how wide a beat is in pixels
    private var pixelsPerBeat: CGFloat

    /// how wide a bar is in pixels
    private var pixelsPerBar: CGFloat

    /// Creates a visual pulse calculator.
    ///
    /// - Parameters:
    ///   - pixelsPerSecond: The zoom level (pixels per second).
    ///   - measure: The measure definition providing pulse durations.
    /// - Throws: If the tempo is zero.
    public init(pixelsPerSecond: Double, measure: MusicalMeasureDescription) throws {
        guard measure.tempo.rawValue > 0 else {
            throw NSError(description: "tempo must be greater than zero")
        }

        self.pixelsPerSecond = pixelsPerSecond
        self.measure = measure

        pixelsPerSubdivision = pixelsPerSecond * measure.duration(pulse: .sixteenth)
        pixelsPerEighth = pixelsPerSecond * measure.duration(pulse: .eighth)
        pixelsPerBeat = pixelsPerSecond * measure.duration(pulse: .quarter)
        pixelsPerBar = pixelsPerSecond * measure.duration(pulse: .bar)
    }

    /// Returns the pixel width of the given pulse at the current zoom level and tempo.
    public func width(of pulse: MusicalPulse) -> CGFloat {
        switch pulse {
        case .bar:
            pixelsPerBar

        case .quarter:
            pixelsPerBeat

        case .eighth:
            pixelsPerEighth

        case .sixteenth:
            pixelsPerSubdivision
        }
    }
}
