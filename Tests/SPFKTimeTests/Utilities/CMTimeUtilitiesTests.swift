// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-time

import CoreMedia
import Foundation
@testable import SPFKTime
import Testing

@Suite("CMTime+Utilities")
struct CMTimeUtilitiesTests {
    // MARK: - stringValue

    @Test("stringValue for zero returns 0s")
    func stringValueZero() {
        let time = CMTime.zero
        #expect(time.stringValue == "0s")
    }

    @Test("stringValue for positive value returns fraction format")
    func stringValuePositive() {
        let time = CMTimeMake(value: 100, timescale: 24)
        #expect(time.stringValue == "100/24s")
    }

    @Test("stringValue for value 1/1 returns fraction format")
    func stringValueOne() {
        #expect(CMTime.one.stringValue == "1/1s")
    }

    @Test("stringValue for negative value returns fraction format")
    func stringValueNegative() {
        let time = CMTimeMake(value: -100, timescale: 24)
        #expect(time.stringValue == "-100/24s")
    }
}
