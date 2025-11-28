
@testable import SPFKTime
import SPFKUtils
import Testing
import SwiftTimecode

class TimecodeDomainTests {
    lazy var td: TimecodeDomain = {
        var td = TimecodeDomain()
        _ = td.setFrameRate(
            to: .fps24,
            preservingValuesIfPossible: false,
            clampPositionToStartTimecode: true
        )

        // double-check defaults before proceeding
        #expect(td.properties.subFramesBase == .max100SubFrames)
        #expect(td.properties.upperLimit == .max24Hours)
        #expect(td.properties.frameRate == .fps24)
        #expect(td.stringFormat == [])

        Log.debug("Created new", td)

        return td
    }()

    // MARK: - Helpers

    @Test func testFormNewTimecode_CalculateElapsedRealTime() throws {
        // just test elapsed time calculation value,
        // don't need to test the setters here; they are tested
        // in other unit tests already

        #expect(td.calculateElapsedRealTime() == 0.0)

        _ = try td.setTimecode(elapsedTime: 3600.0)

        #expect(td.calculateElapsedRealTime() == 3600.0)

        _ = try td.setStartTimecode(seconds: 1000.0,
                                    clampPositionToStartTimecode: true)

        #expect(td.calculateElapsedRealTime() == 2600.0)
    }

    // MARK: - Timecode Factory Methodss

    @Test func testFormNewTimecode_ConvertingFrom1() throws {
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

    // different base settings, different frame rate
    @Test func testFormNewTimecode_ConvertingFrom2() throws {
        let timecode = try Timecode(
            .components(Timecode.Components(h: 1)),
            at: .fps24,
            base: .max80SubFrames,
            limit: .max24Hours
        )

        let tc = try td.formNewTimecode(convertingFrom: timecode)

        #expect(tc.components == Timecode.Components(h: 1, m: 0, s: 0, f: 0, sf: 0))
        #expect(tc.frameRate == .fps24)
        #expect(tc.subFramesBase == .max100SubFrames)
        #expect(tc.upperLimit == .max24Hours)
    }

    // same base settings, different frame rate
    @Test func testFormNewTimecode_ConvertingFrom3() throws {
        let timecode = try Timecode(
            .components(Timecode.Components(h: 1)),
            at: .fps23_976,
            base: .max100SubFrames,
            limit: .max24Hours
        )

        let tc = try td.formNewTimecode(convertingFrom: timecode)

        #expect(tc.components == Timecode.Components(h: 1, m: 0, s: 3, f: 14, sf: 40))
        #expect(tc.frameRate == .fps24)
        #expect(tc.subFramesBase == .max100SubFrames)
        #expect(tc.upperLimit == .max24Hours)
    }

    // different base settings, different frame rate
    @Test func testFormNewTimecode_ConvertingFrom4() throws {
        let timecode = try Timecode(
            .components(Timecode.Components(h: 1)),
            at: .fps23_976,
            base: .max80SubFrames,
            limit: .max24Hours
        )

        let tc = try td.formNewTimecode(convertingFrom: timecode)

        #expect(tc.components == Timecode.Components(h: 1, m: 0, s: 3, f: 14, sf: 40))
        #expect(tc.frameRate == .fps24)
        #expect(tc.subFramesBase == .max100SubFrames)
        #expect(tc.upperLimit == .max24Hours)
    }

    @Test func testFormNewTimecode_String() throws {
        let tc = try td.formNewTimecode(string: "01:02:03:04")

        #expect(tc.components == Timecode.Components(h: 1, m: 2, s: 3, f: 4))
        #expect(tc.frameRate == .fps24)
        #expect(tc.subFramesBase == .max100SubFrames)
        #expect(tc.upperLimit == .max24Hours)

        // invalid

        #expect((try? td.formNewTimecode(string: "blahblah")) == nil)
    }

    @Test func testFormNewTimecode_Components() throws {
        let tc = td.formNewTimecode(components: Timecode.Components(h: 1, m: 2, s: 3, f: 4))

        #expect(tc.components == Timecode.Components(h: 1, m: 2, s: 3, f: 4))
        #expect(tc.frameRate == .fps24)
        #expect(tc.subFramesBase == .max100SubFrames)
        #expect(tc.upperLimit == .max24Hours)
    }

    @Test func testFormNewTimecode_Components_RawValues1() throws {
        let tc = td.formNewTimecode(components: Timecode.Components(h: 1, m: 2, s: 3, f: 4))

        #expect(tc.components == Timecode.Components(h: 1, m: 2, s: 3, f: 4))
        #expect(tc.frameRate == .fps24)
        #expect(tc.subFramesBase == .max100SubFrames)
        #expect(tc.upperLimit == .max24Hours)
    }

    // valid rawValues
    @Test func testFormNewTimecode_Components_RawValues2() throws {
        let tc = td.formNewTimecode(components: Timecode.Components(h: 99, m: 99, s: 99, f: 99), by: .allowingInvalid)

        #expect(tc.components == Timecode.Components(h: 99, m: 99, s: 99, f: 99))
        #expect(tc.frameRate == .fps24)
        #expect(tc.subFramesBase == .max100SubFrames)
        #expect(tc.upperLimit == .max24Hours)
    }

    @Test func testFormNewTimecode_Seconds() throws {
        let tc = td.formNewTimecode(wrappingRealTimeSeconds: 3600.0)

        #expect(tc.components == Timecode.Components(h: 1, m: 0, s: 0, f: 0))
        #expect(tc.frameRate == .fps24)
        #expect(tc.subFramesBase == .max100SubFrames)
        #expect(tc.upperLimit == .max24Hours)

        // wrapping

        let tcWrapped1 = td.formNewTimecode(wrappingRealTimeSeconds: -1.0)
        #expect(tcWrapped1.stringValue() == "23:59:59:00")

        let tcWrapped2 = td.formNewTimecode(wrappingRealTimeSeconds: 60 * 60 * 25) // 25 hours
        #expect(tcWrapped2.stringValue() == "01:00:00:00")
    }

    @Test func testFormNewSignedTimecode1() throws {
        let signedTC = td.formNewSignedTimecode(seconds: 3600.0)

        #expect(signedTC.sign == .plus)

        let tc = signedTC.timecode

        #expect(tc.components == Timecode.Components(h: 1, m: 0, s: 0, f: 0))
        #expect(tc.frameRate == .fps24)
        #expect(tc.subFramesBase == .max100SubFrames)
        #expect(tc.upperLimit == .max24Hours)
    }

    @Test func testFormNewSignedTimecode2() throws {
        let signedTC = td.formNewSignedTimecode(seconds: -3600.0)

        #expect(signedTC.sign == .minus)

        let tc = signedTC.timecode
        #expect(tc.components == Timecode.Components(h: 1, m: 0, s: 0, f: 0))
        #expect(tc.frameRate == .fps24)
        #expect(tc.subFramesBase == .max100SubFrames)
        #expect(tc.upperLimit == .max24Hours)
    }

    @Test func testTimecodeSecond() throws {
        let allCases = TimecodeFrameRate.allCases

        for value in allCases {
            _ = td.setFrameRate(
                to: value,
                preservingValuesIfPossible: false,
                clampPositionToStartTimecode: true
            )

            if td.frameRate.isDrop {
                #expect(td.timecodeSecond < 1)

            } else {
                #expect(td.timecodeSecond >= 1)
            }

            Log.debug(td.frameRate, "timecodeSecond: ", td.timecodeSecond)
        }
    }
}
