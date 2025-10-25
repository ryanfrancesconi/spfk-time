
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

struct VisualMusicalTimeRegressionTests {
    // MARK: - these values are pulled from ShadowTag. use for regression tests.

    @Test(arguments: [1, 2, 3, 4])
    func timeToNearest(time: TimeInterval) throws {
        #expect(VisualMusicalTime(pixelsPerSecond: 144.33333333333334, tempo: 60.0, timeSignature: try TimeSignature(numerator: 4, denominator: 4)).timeToNearest(pulse: .quarter, at: time, direction: .forward) == 1.0)

        #expect(VisualMusicalTime(pixelsPerSecond: 144.33333333333334, tempo: 60.0, timeSignature: try TimeSignature(numerator: 4, denominator: 4)).timeToNearest(pulse: .quarter, at: time, direction: .backward) == -1.0)
    }

    @Test func timeToNearest_nearZero() throws {
        let expected = VisualMusicalTime(
            pixelsPerSecond: 185.66923647278477,
            tempo: 77.0,
            timeSignature: try TimeSignature(numerator: 4, denominator: 4)
        ).timeToNearest(
            pulse: .quarter,
            at: 4.675324675324676,
            direction: .backward
        )

        #expect(expected == -0.7792207792207793)

        // timeTillNextPulse 4.440892098500626e-16
        #expect(VisualMusicalTime(pixelsPerSecond: 185.66923647278477, tempo: 77.0, timeSignature: try TimeSignature(numerator: 4, denominator: 4)).timeToNearest(pulse: .quarter, at: 2.337662337662338, direction: .forward) == 0.7792207792207793)

        // timeTillNextPulse 0.9999999999999991
        #expect(VisualMusicalTime(pixelsPerSecond: 185.66923647278477, tempo: 77.0, timeSignature: try TimeSignature(numerator: 4, denominator: 4)).timeToNearest(pulse: .quarter, at: 4.675324675324675, direction: .forward) == 0.7792207792207793)
    }

    @Test func timeToNearest_partials() throws {
        // timeTillNextPulse 0.8884869370669746
        #expect(VisualMusicalTime(pixelsPerSecond: 144.33333333333334, tempo: 60.0, timeSignature: try TimeSignature(numerator: 4, denominator: 4)).timeToNearest(pulse: .quarter, at: 0.8884869370669746, direction: .forward) == 0.11151306293302543)

        #expect(VisualMusicalTime(pixelsPerSecond: 144.33333333333334, tempo: 60.0, timeSignature: try TimeSignature(numerator: 4, denominator: 4)).timeToNearest(pulse: .quarter, at: 1.162736359699769, direction: .forward) == 0.8372636403002309)

        #expect(VisualMusicalTime(pixelsPerSecond: 144.33333333333334, tempo: 60.0, timeSignature: try TimeSignature(numerator: 4, denominator: 4)).timeToNearest(pulse: .quarter, at: 1.6173769486143186, direction: .backward) == -0.6173769486143186)

        #expect(VisualMusicalTime(pixelsPerSecond: 144.33333333333334, tempo: 60.0, timeSignature: try TimeSignature(numerator: 4, denominator: 4)).timeToNearest(pulse: .quarter, at: 7.35204063221709, direction: .forward) == 0.6479593677829101)
    }
}
