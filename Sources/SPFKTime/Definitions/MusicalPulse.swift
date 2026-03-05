import Foundation

/// A rhythmic subdivision level used for duration calculations and grid snapping.
public enum MusicalPulse: String, Equatable, Codable, Hashable, CaseIterable, Sendable {
    /// One full measure.
    case bar

    /// A quarter note.
    case quarter

    /// An eighth note (half a quarter note).
    case eighth

    /// A sixteenth note (quarter of a quarter note).
    case sixteenth
}
