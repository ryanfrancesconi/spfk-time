
import Foundation
@testable import SPFKTime
import SPFKUtils
import Testing

struct VisualMusicalPulseTests {
    @Test func initValues() throws {
        let measure30 = MusicalMeasureDescription(timeSignature: ._4_4, tempo: 30)
        let measure60 = MusicalMeasureDescription(timeSignature: ._4_4, tempo: 60)
        let measure120 = MusicalMeasureDescription(timeSignature: ._4_4, tempo: 120)

        let vmp = try VisualMusicalPulse(pixelsPerSecond: 60, measure: measure60)
        #expect(vmp.width(of: .bar) == 240)
        #expect(vmp.width(of: .beat) == 60)
        #expect(vmp.width(of: .subdivision) == 15)

        let vmp2 = try VisualMusicalPulse(pixelsPerSecond: 30, measure: measure60)
        #expect(vmp2.width(of: .bar) == 120)
        #expect(vmp2.width(of: .beat) == 30)
        #expect(vmp2.width(of: .subdivision) == 7.5)

        let vmp3 = try VisualMusicalPulse(pixelsPerSecond: 30, measure: measure120)
        #expect(vmp3.width(of: .bar) == 60)
        #expect(vmp3.width(of: .beat) == 15)
        #expect(vmp3.width(of: .subdivision) == 3.75)

        let vmp4 = try VisualMusicalPulse(pixelsPerSecond: 10, measure: measure30)
        #expect(vmp4.width(of: .bar) == 80)
        #expect(vmp4.width(of: .beat) == 20)
        #expect(vmp4.width(of: .subdivision) == 5)
    }
}
