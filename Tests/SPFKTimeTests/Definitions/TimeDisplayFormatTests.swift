// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-time

import Foundation
@testable import SPFKTime
import Testing

@Suite("TimeDisplayFormat")
struct TimeDisplayFormatTests {
    @Test("title returns display name")
    func titleValues() {
        #expect(TimeDisplayFormat.timecode.title == "Timecode")
        #expect(TimeDisplayFormat.seconds.title == "Seconds")
    }

    @Test("init from valid title string")
    func initFromTitle() {
        #expect(TimeDisplayFormat(title: "Timecode") == .timecode)
        #expect(TimeDisplayFormat(title: "Seconds") == .seconds)
    }

    @Test("init from invalid title returns nil")
    func initFromInvalidTitle() {
        #expect(TimeDisplayFormat(title: "timecode") == nil)
        #expect(TimeDisplayFormat(title: "SMPTE") == nil)
        #expect(TimeDisplayFormat(title: "") == nil)
    }

    @Test("raw values")
    func rawValues() {
        #expect(TimeDisplayFormat.timecode.rawValue == "timecode")
        #expect(TimeDisplayFormat.seconds.rawValue == "seconds")
    }

    @Test("all cases")
    func allCases() {
        #expect(TimeDisplayFormat.allCases.count == 2)
    }
}
