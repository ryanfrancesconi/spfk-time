// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-time

import Foundation
import SPFKBase
@testable import SPFKTime
import SPFKUtils
import Testing

struct VisualMusicalTimeTests {
    /// visualPulse must be nil when bpm or timeSignature is absent — callers gate snap
    /// behavior on this being non-nil, so any change to the guard logic would break snapping.
    @Test func visualPulseNilWhenInputsMissing() {
        var vt = VisualMusicalTime()
        #expect(vt.visualPulse == nil, "no bpm, no timeSignature → nil")

        vt.bpm = .bpm120
        #expect(vt.visualPulse == nil, "bpm set but no timeSignature → still nil")

        vt.bpm = nil
        vt.timeSignature = ._4_4
        #expect(vt.visualPulse == nil, "timeSignature set but no bpm → still nil")

        vt.bpm = .bpm120
        #expect(vt.visualPulse != nil, "both set → non-nil")
    }


    @Test func width_4_4_60() {
        var visualTime = VisualMusicalTime()
        visualTime.timeSignature = ._4_4
        visualTime.bpm = .bpm60
        visualTime.pixelsPerSecond = 60

        #expect(visualTime.visualPulse?.width(of: .bar) == 240)
        #expect(visualTime.visualPulse?.width(of: .quarter) == 60)
        #expect(visualTime.visualPulse?.width(of: .sixteenth) == 15)
    }

    // should match width_4_4_60
    @Test func width_8_8_60() {
        var visualTime = VisualMusicalTime()
        visualTime.timeSignature = ._8_8
        visualTime.bpm = .bpm60
        visualTime.pixelsPerSecond = 60

        #expect(visualTime.visualPulse?.width(of: .bar) == 240)
        #expect(visualTime.visualPulse?.width(of: .quarter) == 60)
        #expect(visualTime.visualPulse?.width(of: .sixteenth) == 15)
    }

    @Test func width_4_4_120() {
        var visualTime = VisualMusicalTime()
        visualTime.timeSignature = ._4_4
        visualTime.bpm = .bpm120
        visualTime.pixelsPerSecond = 30

        #expect(visualTime.visualPulse?.width(of: .bar) == 60)
        #expect(visualTime.visualPulse?.width(of: .quarter) == 15)
        #expect(visualTime.visualPulse?.width(of: .sixteenth) == 3.75)
    }
}
