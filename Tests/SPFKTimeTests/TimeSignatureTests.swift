
@testable import SPFKTime
import Testing

class TimeSignatureTests {
    @Test func testValidArguments() throws {
        // valid
        #expect((try? TimeSignature(numerator: 2, denominator: 2)) != nil)
        #expect((try? TimeSignature(numerator: 3, denominator: 4)) != nil)
        #expect((try? TimeSignature(numerator: 4, denominator: 16)) != nil)
        #expect((try? TimeSignature(numerator: 5, denominator: 32)) != nil)
        #expect((try? TimeSignature(numerator: 5, denominator: 64)) != nil)

        // invalid
        #expect((try? TimeSignature(numerator: 4, denominator: 1)) == nil)
        #expect((try? TimeSignature(numerator: 4, denominator: 3)) == nil)
        #expect((try? TimeSignature(numerator: 4, denominator: 15)) == nil)
    }
}
