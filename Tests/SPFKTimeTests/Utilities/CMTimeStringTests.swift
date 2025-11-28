
import CoreMedia
import Numerics
import SPFKTime
import SPFKUtils
import Testing
import SwiftTimecode

class CMTimeStringTests {
    @Test func testCMTimeParser() {
        let cmTime = CMTimeString.parse(string: "3600s")
        let shouldBe = CMTimeMake(value: 3600, timescale: 1)
        #expect(cmTime == shouldBe)

        let cmTime2 = CMTimeString.parse(string: "576800/9600s")
        let shouldBe2 = CMTimeMake(value: 576800, timescale: 9600)
        #expect(cmTime2 == shouldBe2)
    }

    @Test func testCreateCMTimeStringSeconds() throws {
        // this will be rounded to frame
        let seconds: TimeInterval = 4.0940625

        for frameRate in TimecodeFrameRate.allCases {
            let string = try #require(
                CMTimeString.create(seconds: seconds, frameRate: frameRate)
            )
            // 13101/3200s
            // Log.debug(string)
            let cmTime = try #require(
                CMTimeString.parse(string: string)
            )

            #expect(
                cmTime.seconds.isApproximatelyEqual(to: seconds, relativeTolerance: 0.1)
            )
        }
    }

    @Test func testCreateCMTimeStringFrames() throws {
        try checkTimeString(seconds: 4.0940625)
        try checkTimeString(seconds: 120.0)
        try checkTimeString(seconds: 3600.0)
        try checkTimeString(seconds: 51.718333333333327)
    }

    func checkTimeString(seconds: TimeInterval) throws {
        for frameRate in TimecodeFrameRate.allCases {
            var string = ""

            if let value = CMTimeString.create(seconds: seconds,
                                               frameRate: frameRate) {
                string = value
            }

            let cmTime = try #require(
                CMTimeString.parse(string: string)
            )

            Log.debug("\(frameRate.stringValue)", seconds, "vs", cmTime.seconds, string)

            #expect(cmTime.seconds.isApproximatelyEqual(to: seconds, relativeTolerance: 0.04))
            // XCTAssertLessThanOrEqual(cmTime.seconds, seconds)
        }
    }

    func checkTimeString(seconds: TimeInterval, sampleRate: Double) throws {
        for frameRate in TimecodeFrameRate.allCases {
            var string = ""

            if let value = CMTimeString.create(seconds: seconds,
                                               sampleRate: sampleRate,
                                               frameRate: frameRate) {
                string = value
            }

            let cmTime = try #require(
                CMTimeString.parse(string: string)
            )

            Log.debug("\(frameRate.stringValue)", seconds, "vs", cmTime.seconds, string)

            #expect(cmTime.seconds.isApproximatelyEqual(to: seconds, relativeTolerance: 0.1))
        }
    }

    @Test func testSeconds() throws {
        let seconds = 120.0199

        let timecode = try Timecode(.realTime(seconds: seconds), at: .fps30d)

        Log.debug(seconds, timecode.realTimeValue, timecode.stringValue, timecode.frameCount)

        let timecode2 = try Timecode(.samples(5760000, sampleRate: 48000), at: .fps30d)

        Log.debug(seconds, timecode2.realTimeValue, timecode2.stringValue, timecode2.frameCount)
    }

    @Test func testRealToFraction() throws {
        let realNumber: Double = 51.718333333333327

        for frameRate in TimecodeFrameRate.allCases {
            if let timecode = try? Timecode(.realTime(seconds: realNumber), at: frameRate) {
                let newValue = timecode.rationalValue.doubleValue

                #expect(realNumber.isApproximatelyEqual(to: newValue, relativeTolerance: 0.1))
            }
        }
    }
}

extension CMTimeStringTests {
    @Test func testSecond() {
        Log.debug(CMTime.one.seconds)
    }
}
