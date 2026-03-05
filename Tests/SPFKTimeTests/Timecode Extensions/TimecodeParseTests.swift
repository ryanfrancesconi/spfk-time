// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-time

import Foundation
@testable import SPFKTime
import SwiftTimecode
import Testing

@Suite("Timecode Parse")
struct TimecodeParseTests {
    // MARK: - Delimited input

    @Test("parse full 4-component delimited timecode")
    func parseFullDelimited() {
        let result = Timecode.parseUnformattedTimecode(string: "01:02:03:04", frameRate: .fps24)
        #expect(result?.hours == 1)
        #expect(result?.minutes == 2)
        #expect(result?.seconds == 3)
        #expect(result?.frames == 4)
    }

    @Test("parse 3-component delimited timecode")
    func parse3Component() {
        let result = Timecode.parseUnformattedTimecode(string: "10:30:12", frameRate: .fps24)
        #expect(result?.minutes == 10)
        #expect(result?.seconds == 30)
        #expect(result?.frames == 12)
        #expect(result?.hours == 0)
    }

    @Test("parse 2-component delimited timecode")
    func parse2Component() {
        let result = Timecode.parseUnformattedTimecode(string: "5:10", frameRate: .fps24)
        #expect(result?.seconds == 5)
        #expect(result?.frames == 10)
        #expect(result?.hours == 0)
        #expect(result?.minutes == 0)
    }

    @Test("parse 1-component delimited timecode")
    func parse1Component() {
        let result = Timecode.parseUnformattedTimecode(string: "15", frameRate: .fps24)
        #expect(result?.frames == 15)
        #expect(result?.hours == 0)
        #expect(result?.minutes == 0)
        #expect(result?.seconds == 0)
    }

    @Test("parse 5-component delimited timecode with subframes")
    func parse5Component() {
        let result = Timecode.parseUnformattedTimecode(string: "01:00:10:05:50", frameRate: .fps24)
        #expect(result?.hours == 1)
        #expect(result?.minutes == 0)
        #expect(result?.seconds == 10)
        #expect(result?.frames == 5)
        #expect(result?.subFrames == 50)
    }

    // MARK: - Delimiter types

    @Test("parse with semicolon delimiters")
    func parseSemicolonDelimiters() {
        let result = Timecode.parseUnformattedTimecode(string: "01;02;03;04", frameRate: .fps24)
        #expect(result?.hours == 1)
        #expect(result?.minutes == 2)
        #expect(result?.seconds == 3)
        #expect(result?.frames == 4)
    }

    @Test("parse with dot delimiters")
    func parseDotDelimiters() {
        let result = Timecode.parseUnformattedTimecode(string: "01.02.03.04", frameRate: .fps24)
        #expect(result?.hours == 1)
        #expect(result?.minutes == 2)
        #expect(result?.seconds == 3)
        #expect(result?.frames == 4)
    }

    // MARK: - Undelimited input

    @Test("parse undelimited digits at 2-digit frame rate")
    func parseUndelimited2Digit() {
        // "01020304" at fps24 (2 digit frames): 01:02:03:04
        let result = Timecode.parseUnformattedTimecode(string: "01020304", frameRate: .fps24)
        #expect(result?.hours == 1)
        #expect(result?.minutes == 2)
        #expect(result?.seconds == 3)
        #expect(result?.frames == 4)
    }

    @Test("parse short undelimited digits")
    func parseShortUndelimited() {
        // "1234" at fps24: splits from right as 12:34 -> seconds:frames
        let result = Timecode.parseUnformattedTimecode(string: "1234", frameRate: .fps24)
        #expect(result?.seconds == 12)
        #expect(result?.frames == 34)
    }

    @Test("parse returns nil for too many undelimited components")
    func parseTooManyUndelimited() {
        // 10 digits at fps24 -> 5 components, exceeds max of 4
        let result = Timecode.parseUnformattedTimecode(string: "0102030405", frameRate: .fps24)
        #expect(result == nil)
    }

    // MARK: - Edge cases

    @Test("parse empty string returns frames 0")
    func parseEmptyString() {
        let result = Timecode.parseUnformattedTimecode(string: "", frameRate: .fps24)
        // empty splits into 1 component with empty string, int conversion gives 0
        #expect(result?.frames == 0)
    }

    @Test("parse zero timecode")
    func parseZero() {
        let result = Timecode.parseUnformattedTimecode(string: "00:00:00:00", frameRate: .fps24)
        #expect(result?.hours == 0)
        #expect(result?.minutes == 0)
        #expect(result?.seconds == 0)
        #expect(result?.frames == 0)
    }

    @Test("parse with mixed delimiters")
    func parseMixedDelimiters() {
        let result = Timecode.parseUnformattedTimecode(string: "01:02.03;04", frameRate: .fps24)
        #expect(result?.hours == 1)
        #expect(result?.minutes == 2)
        #expect(result?.seconds == 3)
        #expect(result?.frames == 4)
    }
}
