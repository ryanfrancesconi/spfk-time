// Copyright Ryan Francesconi. All Rights Reserved.

import Foundation
import SwiftTimecode
import Testing

@testable import SPFKTime

/// An editable readout formats in one domain and has to parse in the same one. Parsing real time
/// while displaying timecode shows a value the user cannot type back — and with a start offset it
/// is wrong by the offset as well.
@Suite
final class TimeFormatterParseTests {
    private func formatter(
        domain: TimeDomain,
        frameRate: TimecodeFrameRate = .fps30,
        start: String? = nil
    ) throws -> TimeFormatter {
        var formatter = TimeFormatter(primaryDomain: domain)
        formatter.update(frameRate: frameRate)

        if let start {
            try formatter.update(start: Timecode(.string(start), at: frameRate))
        }

        return formatter
    }

    // MARK: - Round trip

    /// The property that matters: whatever the readout shows, typing it back gives the position it
    /// was showing.
    @Test(arguments: [0.0, 1.5, 10.0, 3599.5] as [TimeInterval])
    func realTimeRoundTrips(elapsed: TimeInterval) throws {
        var formatter = try formatter(domain: .realTime)
        formatter.update(elapsedTime: elapsed)

        let parsed = try #require(formatter.elapsedTime(fromPrimaryString: formatter.primaryString))

        #expect(abs(parsed - elapsed) < 0.001)
    }

    @Test(arguments: [0.0, 1.5, 10.0, 600.0] as [TimeInterval])
    func timecodeRoundTripsWithNoStartOffset(elapsed: TimeInterval) throws {
        var formatter = try formatter(domain: .timecode)
        formatter.update(elapsedTime: elapsed)

        let parsed = try #require(formatter.elapsedTime(fromPrimaryString: formatter.primaryString))

        // A timecode string carries whole frames, so a position mid-frame comes back quantized.
        #expect(abs(parsed - elapsed) < 1.0 / 30)
    }

    /// The case the start-timecode work created: the readout shows an absolute timecode an hour
    /// along, and the transport wants elapsed seconds from the file's first sample.
    @Test(arguments: [0.0, 10.0, 125.5] as [TimeInterval])
    func timecodeRoundTripsThroughAStartOffset(elapsed: TimeInterval) throws {
        var formatter = try formatter(domain: .timecode, start: "01:00:00:00")
        formatter.update(elapsedTime: elapsed)

        let displayed = formatter.primaryString
        #expect(displayed.hasPrefix("01:"), "expected an offset readout, got \(displayed)")

        let parsed = try #require(formatter.elapsedTime(fromPrimaryString: displayed))

        #expect(abs(parsed - elapsed) < 1.0 / 30)
    }

    /// Drop frame renumbers rather than retimes, so the string and the real-time value diverge in a
    /// way a naive `h*3600 + m*60 + s` parse gets wrong.
    @Test func timecodeRoundTripsAtDropFrame() throws {
        var formatter = try formatter(domain: .timecode, frameRate: .fps29_97d, start: "01:00:00;01")
        formatter.update(elapsedTime: 61)

        let parsed = try #require(formatter.elapsedTime(fromPrimaryString: formatter.primaryString))

        #expect(abs(parsed - 61) < 1.0 / 29.97)
    }

    // MARK: - The bug this replaced

    /// Parsing a timecode string as wall clock silently drops the frames field and ignores the
    /// offset entirely. Pinned as a differential so a revert to the old behavior fails here.
    @Test func timecodeStringIsNotReadAsWallClock() throws {
        let formatter = try formatter(domain: .timecode, start: "01:00:00:00")

        let parsed = try #require(formatter.elapsedTime(fromPrimaryString: "01:00:10:00"))

        #expect(abs(parsed - 10) < 0.001)
        #expect(abs(parsed - 3610) > 1, "read as an absolute position rather than elapsed")
    }

    // MARK: - Domain selection

    /// The same string means different things in each domain, which is the whole reason the parse
    /// has to consult `primaryDomain` rather than assume.
    @Test func theSameStringParsesDifferentlyPerDomain() throws {
        let realTime = try formatter(domain: .realTime)
        let timecode = try formatter(domain: .timecode)

        let asRealTime = try #require(realTime.elapsedTime(fromPrimaryString: "00:01:30"))
        #expect(abs(asRealTime - 90) < 0.001)

        let asTimecode = try #require(timecode.elapsedTime(fromPrimaryString: "00:00:01:15"))
        #expect(abs(asTimecode - 1.5) < 0.001)
    }

    @Test func unparseableInputIsRejectedRatherThanGuessed() throws {
        let timecode = try formatter(domain: .timecode)

        #expect(timecode.elapsedTime(fromPrimaryString: "not a time") == nil)

        // 45 frames does not exist at 30 fps — a position the file cannot hold is no position.
        #expect(timecode.elapsedTime(fromPrimaryString: "00:00:01:45") == nil)
    }

    /// The musical domain formats to an empty string, so there is nothing to parse back.
    @Test func musicalDomainParsesNothing() throws {
        let musical = try formatter(domain: .musical)

        #expect(musical.elapsedTime(fromPrimaryString: "1|1|000") == nil)
    }
}
