import Foundation
import SPFKUtils

public struct VisualMusicalPulse: Equatable, Codable {
    private static let subdivisionsPerBeat: CGFloat = 4

    public private(set) var measure: MusicalMeasureDescription

    /// how many pixels in one second of time
    public private(set) var pixelsPerSecond: Double

    /// How wide a 1/16 note is in pixels
    private var pixelsPerSubdivision: CGFloat

    /// how wide a beat is in pixels
    private var pixelsPerBeat: CGFloat

    /// how wide a bar is in pixels
    private var pixelsPerBar: CGFloat

    public init(pixelsPerSecond: Double, measure: MusicalMeasureDescription) throws {
        guard measure.tempo > 0 else {
            throw NSError(description: "tempo must be greater than zero")
        }

        self.pixelsPerSecond = pixelsPerSecond
        self.measure = measure

        pixelsPerSubdivision = pixelsPerSecond * measure.duration(pulse: .subdivision)
        pixelsPerBeat = pixelsPerSecond * measure.duration(pulse: .beat)
        pixelsPerBar = pixelsPerSecond * measure.duration(pulse: .bar)
    }

    public func width(of pulse: MusicalPulse) -> CGFloat {
        switch pulse {
        case .bar:
            pixelsPerBar

        case .beat:
            pixelsPerBeat

        case .subdivision:
            pixelsPerSubdivision
        }
    }
}
