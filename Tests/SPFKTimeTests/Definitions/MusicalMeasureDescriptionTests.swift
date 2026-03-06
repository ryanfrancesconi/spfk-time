// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-time

import Foundation
import SPFKAudioBase
import SPFKUtils
import Testing

@testable import SPFKTime

struct MusicalMeasureDescriptionTests {
    @Test func generateTests() throws {
        Swift.print(MusicalMeasureDescription(timeSignature: ._1_4, bpm: .bpm60).debugDescription)
        Swift.print(MusicalMeasureDescription(timeSignature: ._2_4, bpm: .bpm60).debugDescription)
        Swift.print(MusicalMeasureDescription(timeSignature: ._3_4, bpm: .bpm60).debugDescription)
        Swift.print(MusicalMeasureDescription(timeSignature: ._4_4, bpm: .bpm60).debugDescription)
        Swift.print("// 8/8")
        Swift.print(MusicalMeasureDescription(timeSignature: ._8_8, bpm: .bpm60).debugDescription)
    }

    @Test func timeToTestValue_barsPerSecond() throws {
        #expect(MusicalMeasureDescription(timeSignature: ._1_4, bpm: .bpm60).barsPerSecond == 1)
        #expect(MusicalMeasureDescription(timeSignature: ._2_4, bpm: .bpm60).barsPerSecond == 0.5)
        #expect(MusicalMeasureDescription(timeSignature: ._3_4, bpm: .bpm60).barsPerSecond == 0.3333333333333333)
        #expect(MusicalMeasureDescription(timeSignature: ._4_4, bpm: .bpm60).barsPerSecond == 0.25)
        #expect(MusicalMeasureDescription(timeSignature: ._8_8, bpm: .bpm60).barsPerSecond == 0.25)
        #expect(MusicalMeasureDescription(timeSignature: ._16_16, bpm: .bpm60).barsPerSecond == 0.25)
    }

    @Test func durations() throws {
        let _3_4 = MusicalMeasureDescription(timeSignature: ._3_4, bpm: .bpm60)
        let _6_8 = MusicalMeasureDescription(timeSignature: ._6_8, bpm: .bpm60)
        let _12_16 = MusicalMeasureDescription(timeSignature: ._12_16, bpm: .bpm60)

        Log.debug(_3_4.testValue, _6_8.testValue, _12_16.testValue)

        #expect(_3_4.duration(pulse: .bar) == 3)
        #expect(_6_8.duration(pulse: .bar) == 3)
        #expect(_12_16.duration(pulse: .bar) == 3)
        #expect(_3_4.duration(pulse: .quarter) == 1)
        #expect(_6_8.duration(pulse: .quarter) == 1)
        #expect(_12_16.duration(pulse: .quarter) == 1)

        let _4_4 = MusicalMeasureDescription(timeSignature: ._4_4, bpm: .bpm60)
        let _8_8 = MusicalMeasureDescription(timeSignature: ._8_8, bpm: .bpm60)
        let _16_16 = MusicalMeasureDescription(timeSignature: ._8_8, bpm: .bpm60)

        #expect(_4_4.duration(pulse: .bar) == 4)
        #expect(_8_8.duration(pulse: .bar) == 4)
        #expect(_16_16.duration(pulse: .bar) == 4)
    }
}

extension MusicalMeasureDescriptionTests {
    // MARK: - these values are pulled from ShadowTag. use for regression tests.

    @Test(arguments: [1, 2, 3, 4])
    func timeToNearestSecond(time: TimeInterval) throws {
        #expect(
            MusicalMeasureDescription.timeToNearest(
                pulse: .quarter,
                measure: MusicalMeasureDescription(timeSignature: ._4_4, bpm: .bpm60),
                at: time,
                direction: .forward
            ) == 1.0
        )

        #expect(
            MusicalMeasureDescription.timeToNearest(
                pulse: .quarter,
                measure: MusicalMeasureDescription(timeSignature: ._4_4, bpm: .bpm60),
                at: time,
                direction: .backward
            ) == -1.0
        )
    }

    @Test(arguments: [0.5, 1.5, 2.5, 3.5])
    func timeToNearestFraction(time: TimeInterval) throws {
        #expect(
            MusicalMeasureDescription.timeToNearest(
                pulse: .quarter,
                measure: MusicalMeasureDescription(timeSignature: ._4_4, bpm: .bpm60),
                at: time,
                direction: .forward
            ) == 0.5
        )

        #expect(
            MusicalMeasureDescription.timeToNearest(
                pulse: .quarter,
                measure: MusicalMeasureDescription(timeSignature: ._4_4, bpm: .bpm60),
                at: time,
                direction: .backward
            ) == -0.5
        )
    }

    @Test func timeToNearest_nearZero() throws {
        #expect(
            MusicalMeasureDescription.timeToNearest(
                pulse: .quarter,
                measure: MusicalMeasureDescription(timeSignature: ._4_4, bpm: Bpm(77)!),
                at: 4.675324675324676,
                direction: .backward
            ) == -0.7792207792207793
        )

        #expect(
            MusicalMeasureDescription.timeToNearest(
                pulse: .quarter,
                measure: MusicalMeasureDescription(timeSignature: ._4_4, bpm: Bpm(77)!),
                at: 2.337662337662338,
                direction: .forward
            ) == 0.7792207792207793
        )

        #expect(
            MusicalMeasureDescription.timeToNearest(
                pulse: .quarter,
                measure: MusicalMeasureDescription(timeSignature: ._4_4, bpm: Bpm(77)!),
                at: 4.675324675324675,
                direction: .forward
            ) == 0.7792207792207793
        )
    }

    @Test func timeToNearest_partials() throws {
        #expect(
            try MusicalMeasureDescription.timeToNearest(
                pulse: .quarter,
                measure: MusicalMeasureDescription(
                    timeSignature: TimeSignature(numerator: 4, denominator: 4), bpm: Bpm(77)!
                ),
                at: 0.7224288473856091, direction: .forward
            ) == 0.0567919318351702)

        #expect(
            try MusicalMeasureDescription.timeToNearest(
                pulse: .quarter,
                measure: MusicalMeasureDescription(
                    timeSignature: TimeSignature(numerator: 4, denominator: 4), bpm: Bpm(77)!
                ),
                at: 1.0965821068039117, direction: .forward
            ) == 0.4618594516376469)

        #expect(
            try MusicalMeasureDescription.timeToNearest(
                pulse: .quarter,
                measure: MusicalMeasureDescription(
                    timeSignature: TimeSignature(numerator: 4, denominator: 4), bpm: Bpm(77)!
                ), at: 5.156536292377851,
                direction: .backward
            ) == -0.481211617053175)
    }
}
