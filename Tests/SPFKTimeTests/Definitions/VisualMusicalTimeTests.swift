
import Foundation
@testable import SPFKTime
import SPFKUtils
import Testing

struct VisualMusicalTimeTests {
    @Test func width_4_4_60() {
        var visualTime = VisualMusicalTime()
        visualTime.timeSignature = ._4_4
        visualTime.tempo = 60
        visualTime.pixelsPerSecond = 60

        #expect(visualTime.visualPulse?.width(of: .bar) == 240)
        #expect(visualTime.visualPulse?.width(of: .quarter) == 60)
        #expect(visualTime.visualPulse?.width(of: .sixteenth) == 15)
    }

    // should match width_4_4_60
    @Test func width_8_8_60() {
        var visualTime = VisualMusicalTime()
        visualTime.timeSignature = ._8_8
        visualTime.tempo = 60
        visualTime.pixelsPerSecond = 60

        #expect(visualTime.visualPulse?.width(of: .bar) == 240)
        #expect(visualTime.visualPulse?.width(of: .quarter) == 60)
        #expect(visualTime.visualPulse?.width(of: .sixteenth) == 15)
    }

    @Test func width_4_4_120() {
        var visualTime = VisualMusicalTime()
        visualTime.timeSignature = ._4_4
        visualTime.tempo = 120
        visualTime.pixelsPerSecond = 30

        #expect(visualTime.visualPulse?.width(of: .bar) == 60)
        #expect(visualTime.visualPulse?.width(of: .quarter) == 15)
        #expect(visualTime.visualPulse?.width(of: .sixteenth) == 3.75)
    }
}
