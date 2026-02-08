import Foundation
import SPFKUtils

public struct VisualMusicalPulse: Equatable, Codable, Sendable {
    public private(set) var measure: MusicalMeasureDescription

    /// how many pixels in one second of time
    public private(set) var pixelsPerSecond: Double

    /// How wide a 1/16 note is in pixels
    private var pixelsPerSubdivision: CGFloat

    private var pixelsPerEighth: CGFloat

    /// how wide a beat is in pixels
    private var pixelsPerBeat: CGFloat

    /// how wide a bar is in pixels
    private var pixelsPerBar: CGFloat

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
