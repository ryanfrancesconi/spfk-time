@testable import SPFKTime
import SwiftTimecode
import Testing

extension TimecodeDomainTests {
    @Test func testFormNewTimecode_PreservingValuesFrom1() throws {
        // same base settings, same frame rate

        let timecode = try Timecode(
            .components(Timecode.Components(h: 1)),
            at: .fps24,
            base: .max100SubFrames,
            limit: .max24Hours
        )

        let tc = try td.formNewTimecode(convertingFrom: timecode)

        #expect(tc.components == Timecode.Components(h: 1, m: 0, s: 0, f: 0, sf: 0))
        #expect(tc.frameRate == .fps24)
        #expect(tc.subFramesBase == .max100SubFrames)
        #expect(tc.upperLimit == .max24Hours)
    }

    @Test func testFormNewTimecode_PreservingValuesFrom2() throws {
        // different base settings, different frame rate

        let timecode = try Timecode(
            .components(Timecode.Components(h: 1)),
            at: .fps24,
            base: .max80SubFrames,
            limit: .max100Days
        )

        let tc = try td.formNewTimecode(convertingFrom: timecode)

        #expect(tc.components == Timecode.Components(h: 1, m: 0, s: 0, f: 0, sf: 0))
        #expect(tc.frameRate == .fps24)
        #expect(tc.subFramesBase == .max100SubFrames)
        #expect(tc.upperLimit == .max24Hours)
    }

    @Test func testFormNewTimecode_PreservingValuesFrom3() throws {
        // same base settings, different frame rate

        let timecode = try Timecode(
            .components(Timecode.Components(h: 1)),
            at: .fps120d,
            base: .max100SubFrames,
            limit: .max24Hours
        )

        let tc = try td.formNewTimecode(convertingFrom: timecode, by: .clampingComponents)

        #expect(tc.components == Timecode.Components(d: 0, h: 0, m: 59, s: 56, f: 9, sf: 60))
        #expect(tc.frameRate == .fps24)
        #expect(tc.subFramesBase == .max100SubFrames)
        #expect(tc.upperLimit == .max24Hours)
    }

    @Test func testFormNewTimecode_PreservingValuesFrom4() throws {
        // different base settings, different frame rate

        let timecode = try Timecode(
            .components(Timecode.Components(h: 1)),
            at: .fps23_976,
            base: .max80SubFrames,
            limit: .max100Days
        )

        let tc = try td.formNewTimecode(convertingFrom: timecode, by: .clamping)

        #expect(tc.components == Timecode.Components(h: 1, m: 0, s: 3, f: 14, sf: 40))
        #expect(tc.frameRate == .fps24)
        #expect(tc.subFramesBase == .max100SubFrames)
        #expect(tc.upperLimit == .max24Hours)
    }
}
