import Foundation
import SPFKAudioBase
import SPFKUtils
import Testing

@testable import SPFKTime

struct VisualMusicalPulseTests {
    @Test func initValues() throws {
        let measure30 = MusicalMeasureDescription(timeSignature: ._4_4, tempo: Bpm(30)!)
        let measure60 = MusicalMeasureDescription(timeSignature: ._4_4, tempo: Bpm(60)!)
        let measure120 = MusicalMeasureDescription(timeSignature: ._4_4, tempo: Bpm(120)!)

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
