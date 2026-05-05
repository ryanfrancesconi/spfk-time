// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-time

import Foundation
import SPFKBase
import SPFKAudioBase
import SPFKUtils
import Testing

@testable import SPFKTime

struct VisualMusicalPulseTests {
    // MARK: - Snap rounding

    /// Verifies the snap-to-grid rounding used by SelectionEditor: pixel positions should
    /// round to the nearest multiple of the pulse width. A change to `width(of:)` mapping
    /// or the rounding rule would break these expectations.
    @Test func snapToQuarterGrid() throws {
        // 60 BPM, 100 px/s → quarter = 100px, bar = 400px
        let measure = MusicalMeasureDescription(timeSignature: ._4_4, bpm: Bpm(60)!)
        let vmp = try VisualMusicalPulse(pixelsPerSecond: 100, measure: measure)
        let q = vmp.width(of: .quarter)

        #expect(CGFloat(0).round(divisor: q) == 0)
        #expect(CGFloat(49).round(divisor: q) == 0)
        #expect(CGFloat(50).round(divisor: q) == 100)   // midpoint rounds up
        #expect(CGFloat(100).round(divisor: q) == 100)
        #expect(CGFloat(149).round(divisor: q) == 100)
        #expect(CGFloat(150).round(divisor: q) == 200)
        #expect(CGFloat(350).round(divisor: q) == 400)
    }

    /// Verifies bar snap gives the correct wider grid (4× the quarter snap at 4/4).
    @Test func snapToBarGrid() throws {
        let measure = MusicalMeasureDescription(timeSignature: ._4_4, bpm: Bpm(60)!)
        let vmp = try VisualMusicalPulse(pixelsPerSecond: 100, measure: measure)
        let bar = vmp.width(of: .bar)

        #expect(bar == 400)
        #expect(CGFloat(199).round(divisor: bar) == 0)
        #expect(CGFloat(200).round(divisor: bar) == 400)
        #expect(CGFloat(350).round(divisor: bar) == 400)
    }

    /// Confirms that the quarter and bar snap grids produce distinct results for the same
    /// input — guards against a future mapping swap between the two cases.
    @Test func quarterAndBarProduceDifferentSnap() throws {
        let measure = MusicalMeasureDescription(timeSignature: ._4_4, bpm: Bpm(60)!)
        let vmp = try VisualMusicalPulse(pixelsPerSecond: 100, measure: measure)

        let position: CGFloat = 140
        let snappedToQuarter = position.round(divisor: vmp.width(of: .quarter))
        let snappedToBar = position.round(divisor: vmp.width(of: .bar))

        #expect(snappedToQuarter == 100)
        #expect(snappedToBar == 0)
        #expect(snappedToQuarter != snappedToBar)
    }

    // MARK: - Init values

    @Test func initValues() throws {
        let measure30 = MusicalMeasureDescription(timeSignature: ._4_4, bpm: Bpm(30)!)
        let measure60 = MusicalMeasureDescription(timeSignature: ._4_4, bpm: Bpm(60)!)
        let measure120 = MusicalMeasureDescription(timeSignature: ._4_4, bpm: Bpm(120)!)

        let vmp = try VisualMusicalPulse(pixelsPerSecond: 60, measure: measure60)
        #expect(vmp.width(of: .bar) == 240)
        #expect(vmp.width(of: .quarter) == 60)
        #expect(vmp.width(of: .eighth) == 30)
        #expect(vmp.width(of: .sixteenth) == 15)

        let vmp2 = try VisualMusicalPulse(pixelsPerSecond: 30, measure: measure60)
        #expect(vmp2.width(of: .bar) == 120)
        #expect(vmp2.width(of: .quarter) == 30)
        #expect(vmp2.width(of: .eighth) == 15)
        #expect(vmp2.width(of: .sixteenth) == 7.5)

        let vmp3 = try VisualMusicalPulse(pixelsPerSecond: 30, measure: measure120)
        #expect(vmp3.width(of: .bar) == 60)
        #expect(vmp3.width(of: .quarter) == 15)
        #expect(vmp3.width(of: .eighth) == 7.5)
        #expect(vmp3.width(of: .sixteenth) == 3.75)

        let vmp4 = try VisualMusicalPulse(pixelsPerSecond: 10, measure: measure30)
        #expect(vmp4.width(of: .bar) == 80)
        #expect(vmp4.width(of: .quarter) == 20)
        #expect(vmp4.width(of: .eighth) == 10)
        #expect(vmp4.width(of: .sixteenth) == 5)
    }
}
