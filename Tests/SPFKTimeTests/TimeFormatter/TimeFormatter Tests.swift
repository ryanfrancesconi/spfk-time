
import Numerics
@testable import SPFKTime
import Testing
import SwiftTimecode

struct TimeFormatterTests {
    // MARK: - Update Methods

    @Test func testUpdate_ElapsedTime() throws {
        var tt = TimeFormatter(primaryDomain: .timecode)
        let fr: TimecodeFrameRate = .fps23_976
        let tc = try Timecode(.components(h: 1), at: fr)

        tt.update(frameRate: fr)
        tt.update(elapsedTime: tc.realTimeValue)

        #expect(tt.primaryString == "01:00:00:00")
        #expect(tt.realTime.masterSeconds == tc.realTimeValue)
        #expect(tt.timecode.properties.frameRate == fr)
        #expect(tt.timecode.masterTimecode == tc)
    }
    
    @Test func testUpdate_ElapsedTime2() throws {
        var tt = TimeFormatter(primaryDomain: .timecode)
        let fr: TimecodeFrameRate = .fps30d
        let tc = try Timecode(.components(h: 1), at: fr)

        tt.update(frameRate: fr)
        tt.update(elapsedTime: tc.realTimeValue)

        tt.update(start: tc.realTimeValue)
        
        #expect(tt.primaryString == "01:00:00;00")
        #expect(tt.realTime.masterSeconds == tc.realTimeValue)
        #expect(tt.timecode.properties.frameRate == fr)
        #expect(tt.timecode.masterTimecode == tc)
    }

    @Test func testUpdate_Position_Timecode() throws {
        var tt = TimeFormatter(primaryDomain: .timecode)
        let fr: TimecodeFrameRate = .fps23_976
        let tc = try Timecode(.components(h: 1), at: fr)

        tt.update(frameRate: fr)
        tt.update(position: tc)

        #expect(tt.primaryString == "01:00:00:00")
        #expect(tt.realTime.masterSeconds == tc.realTimeValue)
        #expect(tt.timecode.properties.frameRate == fr)
        #expect(tt.timecode.masterTimecode == tc)
    }

    @Test func testUpdate_Position_RealTime() throws {
        var tt = TimeFormatter(primaryDomain: .timecode)
        let fr: TimecodeFrameRate = .fps23_976
        let tc = try Timecode(.components(h: 1), at: fr)

        tt.update(frameRate: fr)
        tt.update(position: tc.realTimeValue)

        #expect(tt.primaryString == "01:00:00:00")
        #expect(tt.realTime.masterSeconds == tc.realTimeValue)
        #expect(tt.timecode.properties.frameRate == fr)
        #expect(tt.timecode.masterTimecode == tc)
    }

    @Test func testUpdate_Start_Timecode() throws {
        var tt = TimeFormatter(primaryDomain: .timecode)
        let fr: TimecodeFrameRate = .fps23_976
        let tc = try Timecode(.components(h: 1), at: fr)

        #expect(tt.primaryString == "00:00:00:00")

        tt.update(frameRate: fr)
        try tt.update(start: tc)

        // if we update start time, the current time shouldn't
        // be allowed to remain prior to the new start time.
        // current time should be updated (clamped) to start time.

        #expect(tt.primaryString == "01:00:00:00")
        #expect(tt.realTime.masterSeconds == 0.0)
        #expect(tt.timecode.properties.frameRate == fr)
    }

    @Test func testUpdate_Start_TimeInterval() throws {
        var tt = TimeFormatter(primaryDomain: .timecode)
        let fr: TimecodeFrameRate = .fps23_976
        let tc = try Timecode(.components(h: 1), at: fr)

        #expect(tt.primaryString == "00:00:00:00")

        tt.update(frameRate: fr)
        tt.update(start: tc.realTimeValue)

        // if we update start time, the current time shouldn't
        // be allowed to remain prior to the new start time.
        // current time should be updated (clamped) to start time.

        #expect(tt.primaryString == "01:00:00:00")
        #expect(tt.realTime.masterSeconds == 0.0)
        #expect(tt.timecode.properties.frameRate == fr)
    }

    @Test func testUpdate_FrameRate_preservingValuesIfPossible_True() throws {
        var tt = TimeFormatter(primaryDomain: .timecode)
        let tc = try Timecode(.components(h: 1), at: .fps23_976)

        tt.update(frameRate: .fps23_976)
        tt.update(start: tc.realTimeValue)
        tt.update(frameRate: .fps24, preservingValuesIfPossible: true)

        #expect(tt.timecode.properties.frameRate == .fps24)

        if let value = try? Timecode(.components(h: 1), at: .fps24) {
            #expect(tt.timecode.startTimecode == value)
        }

        // check that position was clamped to new start timecode
        if let value = try? Timecode(.components(h: 1), at: .fps24) {
            #expect(tt.timecode.masterTimecode == value)
        }

        #expect(tt.primaryString == "01:00:00:00")
        #expect(tt.realTime.masterSeconds == 0.0)
    }

    @Test func testUpdate_FrameRate_preservingValuesIfPossible_False() throws {
        var tt = TimeFormatter(primaryDomain: .timecode)
        let tc = try Timecode(.components(h: 1), at: .fps23_976)

        tt.update(frameRate: .fps23_976)
        tt.update(start: tc.realTimeValue)

        tt.update(frameRate: .fps24, preservingValuesIfPossible: false)

        #expect(tt.timecode.properties.frameRate == .fps24)

        let tcValue = try Timecode(.components(h: 1), at: .fps23_976).realTimeValue
        #expect(
            tt.timecode.startTimecode!.realTimeValue.isApproximatelyEqual(
                to: tcValue,
                relativeTolerance: 0.000_000_000_001
            )
        )

        let tcValue2 = try Timecode(.components(h: 1), at: .fps23_976).realTimeValue
        // check that position was clamped to new start timecode
        #expect(
            tt.timecode.masterTimecode.realTimeValue.isApproximatelyEqual(to: tcValue2, relativeTolerance: 0.000_000_000_001)
        )

        #expect(tt.primaryString == "01:00:03:14")
        #expect(tt.realTime.masterSeconds == 0.0)
    }
}
