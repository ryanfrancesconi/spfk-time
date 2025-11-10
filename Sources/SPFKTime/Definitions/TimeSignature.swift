import Foundation

/// Simple musical time signature.
/// This doesn't support irrational or additive meters.
public struct TimeSignature: Hashable, Codable {
    public static let _4_4: TimeSignature = {
        (try? TimeSignature(numerator: 4, denominator: 4))!
    }()

    public static let _8_8: TimeSignature = {
        (try? TimeSignature(numerator: 8, denominator: 8))!
    }()

    public static let _16_16: TimeSignature = {
        (try? TimeSignature(numerator: 16, denominator: 16))!
    }()

    public static let _3_4: TimeSignature = {
        (try? TimeSignature(numerator: 3, denominator: 4))!
    }()

    public static let _6_8: TimeSignature = {
        (try? TimeSignature(numerator: 6, denominator: 8))!
    }()

    public static let _12_16: TimeSignature = {
        (try? TimeSignature(numerator: 12, denominator: 16))!
    }()

    public static let _2_4: TimeSignature = {
        (try? TimeSignature(numerator: 2, denominator: 4))!
    }()

    public static let _1_4: TimeSignature = {
        (try? TimeSignature(numerator: 1, denominator: 4))!
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

extension TimeSignature: CustomDebugStringConvertible {
    public var debugDescription: String {
        "try TimeSignature(numerator: \(numerator), denominator: \(denominator))"
    }
}
