import Foundation

public struct VisualMusicalPulse: Equatable, Codable {
    private static let subdivisionsPerBeat: CGFloat = 4

    public private(set) var timeSignature: TimeSignature

    public private(set) var tempo: Double

    /// How wide a 1/16 note is in pixels
    public private(set) var pixelsPerSubdivision: CGFloat

    /// how wide a beat is in pixels
    public private(set) var pixelsPerBeat: CGFloat

    /// how wide a bar is in pixels
    public private(set) var pixelsPerBar: CGFloat

    /// how many pixels in one second of time
    public private(set) var pixelsPerSecond: Double

    public init(pixelsPerSecond: Double, tempo: Double, timeSignature: TimeSignature) throws {
        guard tempo > 0 else {
            throw NSError(description: "tempo must be greater than zero")
        }

        self.pixelsPerSecond = pixelsPerSecond
        self.timeSignature = timeSignature
        self.tempo = tempo

        let beatsInSecond: Double = tempo / 60

        pixelsPerSubdivision = CGFloat(pixelsPerSecond / beatsInSecond / Double(timeSignature.numerator))
        pixelsPerBeat = pixelsPerSubdivision * Self.subdivisionsPerBeat
        pixelsPerBar = pixelsPerBeat * CGFloat(timeSignature.numerator)
    }

    public func pixelsPer(pulse: Pulse) -> CGFloat {
        switch pulse {
        case .bar:
            pixelsPerBar

        case .beat:
            pixelsPerBeat

        case .subdivision:
            pixelsPerSubdivision
            
        case .second:
            pixelsPerSecond
        }
    }
}

public enum Pulse: Equatable, Codable, Hashable {
    case bar
    case beat
    case subdivision
    case second
}
