import Foundation

public struct VisualMusicalMeasure: Equatable, Codable {
    private static let subdivisionsPerBeat: CGFloat = 4

    public private(set) var timeSignature: TimeSignature
    public private(set) var tempo: Double

    /// How wide a 1/16 note is in pixels
    public private(set) var pixelsPerSubdivision: CGFloat

    /// how wide a beat is in pixels
    public private(set) var pixelsPerBeat: CGFloat

    /// how wide a bar is in pixels
    public private(set) var pixelsPerBar: CGFloat

    public init(pixelsPerSecond: Double, tempo: Double, timeSignature: TimeSignature) throws {
        guard tempo > 0 else {
            throw NSError(description: "tempo must be greater than zero")
        }

        self.timeSignature = timeSignature
        self.tempo = tempo

        let beatsInSecond: Double = tempo / 60

        pixelsPerSubdivision = CGFloat(pixelsPerSecond / beatsInSecond / Double(timeSignature.numerator))
        pixelsPerBeat = pixelsPerSubdivision * Self.subdivisionsPerBeat
        pixelsPerBar = pixelsPerBeat * CGFloat(timeSignature.numerator)
    }
}
