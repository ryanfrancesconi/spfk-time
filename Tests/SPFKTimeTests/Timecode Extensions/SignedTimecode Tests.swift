
import SPFKTime
import Testing
import SwiftTimecode

class SignedTimecodeTests {
    @Test func testStringValue_Positive() throws {
        let st = SignedTimecode(
            timecode: try Timecode(.components(h: 1, m: 2, s: 3, f: 4), at: .fps24),
            sign: .plus
        )

        #expect(st.stringValue() == "01:02:03:04")
    }

    @Test func testStringValue_Negative() throws {
        let st = SignedTimecode(
            timecode: try Timecode(.components(h: 1, m: 2, s: 3, f: 4), at: .fps24),
            sign: .minus
        )

        #expect(st.stringValue() == "-01:02:03:04")
    }

    @Test func testStringValue_Negative_Zero() throws {
        let st = SignedTimecode(
            timecode: Timecode(.zero, at: .fps24),
            sign: .minus
        )

        #expect(st.stringValue() == "00:00:00:00")
    }
}
