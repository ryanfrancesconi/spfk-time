import Foundation

/// Simple musical time signature.
/// This doesn't support irrational or additive meters.
public struct TimeSignature: Equatable, Codable {
    public static let _4_4: TimeSignature = {
        (try? TimeSignature(numerator: 4, denominator: 4))!
    }()

    public private(set) var numerator: Int
    public private(set) var denominator: Int

    public init(numerator: Int, denominator: Int) throws {
        let isPowerOf2 = (denominator & (denominator - 1) == 0)

        guard numerator > 0, denominator >= 2, isPowerOf2 else {
            throw NSError(description: "invalid arguments: \(numerator)/\(denominator)")
        }

        self.numerator = numerator
        self.denominator = denominator
    }
}
