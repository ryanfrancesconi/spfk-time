import Foundation
@testable import SPFKTime
import SPFKUtils
import Testing

struct MusicalMeasureDescriptionTests {
    @Test func generateTests() throws {
        Swift.print(MusicalMeasureDescription(timeSignature: ._1_4, tempo: 60).debugDescription)
        Swift.print(MusicalMeasureDescription(timeSignature: ._2_4, tempo: 60).debugDescription)
        Swift.print(MusicalMeasureDescription(timeSignature: ._3_4, tempo: 60).debugDescription)
        Swift.print(MusicalMeasureDescription(timeSignature: ._4_4, tempo: 60).debugDescription)
        Swift.print("// 8/8")
        Swift.print(MusicalMeasureDescription(timeSignature: ._8_8, tempo: 60).debugDescription)
    }

    @Test func timeToTestValue_presets() throws {
        #expect(MusicalMeasureDescription(timeSignature: ._1_4, tempo: 60.0).testValue == "quarterNoteDuration: 1.0, barsPerSecond: 1.0, quarterNotesPerSecond: 1.0, sixteenthNotesPerSecond: 0.25")

        #expect(MusicalMeasureDescription(timeSignature: ._2_4, tempo: 60.0).testValue == "quarterNoteDuration: 1.0, barsPerSecond: 0.5, quarterNotesPerSecond: 1.0, sixteenthNotesPerSecond: 0.25")

        #expect(MusicalMeasureDescription(timeSignature: ._3_4, tempo: 60.0).testValue == "quarterNoteDuration: 1.0, barsPerSecond: 0.3333333333333333, quarterNotesPerSecond: 1.0, sixteenthNotesPerSecond: 0.25")

        #expect(MusicalMeasureDescription(timeSignature: ._4_4, tempo: 60.0).testValue == "quarterNoteDuration: 1.0, barsPerSecond: 0.25, quarterNotesPerSecond: 1.0, sixteenthNotesPerSecond: 0.25")
        // 8/8
        #expect(MusicalMeasureDescription(timeSignature: ._8_8, tempo: 60.0).testValue == "quarterNoteDuration: 1.0, barsPerSecond: 0.25, quarterNotesPerSecond: 1.0, sixteenthNotesPerSecond: 0.25")

        #expect(MusicalMeasureDescription(timeSignature: ._16_16, tempo: 60.0).testValue == "quarterNoteDuration: 1.0, barsPerSecond: 0.25, quarterNotesPerSecond: 1.0, sixteenthNotesPerSecond: 0.25")
    }

    @Test func durations() throws {
        let _3_4 = MusicalMeasureDescription(timeSignature: ._3_4, tempo: 60)
        let _6_8 = MusicalMeasureDescription(timeSignature: ._6_8, tempo: 60)
        let _12_16 = MusicalMeasureDescription(timeSignature: ._12_16, tempo: 60)

        Log.debug(_3_4.testValue, _6_8.testValue, _12_16.testValue)

        #expect(_3_4.duration(pulse: .bar) == 3)
        #expect(_6_8.duration(pulse: .bar) == 3)
        #expect(_12_16.duration(pulse: .bar) == 3)
        #expect(_3_4.duration(pulse: .beat) == 1)
        #expect(_6_8.duration(pulse: .beat) == 1)
        #expect(_12_16.duration(pulse: .beat) == 1)

        let _4_4 = MusicalMeasureDescription(timeSignature: ._4_4, tempo: 60)
        let _8_8 = MusicalMeasureDescription(timeSignature: ._8_8, tempo: 60)
        let _16_16 = MusicalMeasureDescription(timeSignature: ._8_8, tempo: 60)

        #expect(_4_4.duration(pulse: .bar) == 4)
        #expect(_8_8.duration(pulse: .bar) == 4)
        #expect(_16_16.duration(pulse: .bar) == 4)
    }
}
