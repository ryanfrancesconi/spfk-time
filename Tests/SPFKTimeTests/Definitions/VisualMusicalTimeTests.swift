
import Foundation
@testable import SPFKTime
import SPFKUtils
import Testing

struct VisualMusicalTimeTests {
    @Test func updateValues_4_4_60() {
        var visualTime = VisualMusicalTime()
        visualTime.timeSignature = ._4_4
        visualTime.tempo = 60
        visualTime.pixelsPerSecond = 60

        #expect(visualTime.visualPulse?.width(of: .bar) == 240)
        #expect(visualTime.visualPulse?.width(of: .beat) == 60)
        #expect(visualTime.visualPulse?.width(of: .subdivision) == 15)
    }

    @Test func updateValues_8_8_60() {
        var visualTime = VisualMusicalTime()
        visualTime.timeSignature = ._8_8
        visualTime.tempo = 60
        visualTime.pixelsPerSecond = 60

        #expect(visualTime.visualPulse?.width(of: .bar) == 240)
        #expect(visualTime.visualPulse?.width(of: .beat) == 60)
        #expect(visualTime.visualPulse?.width(of: .subdivision) == 15)
    }
    
    @Test func updateValues2() {
        var visualTime = VisualMusicalTime()
        visualTime.timeSignature = ._4_4
        visualTime.tempo = 120
        visualTime.pixelsPerSecond = 30

        #expect(visualTime.visualPulse?.width(of: .bar) == 60)
        #expect(visualTime.visualPulse?.width(of: .beat) == 15)
        #expect(visualTime.visualPulse?.width(of: .subdivision) == 3.75)
    }

    @Test(arguments: [0, 0.5])
    func timeToNearest(time: TimeInterval) throws {
        let tempo: Double = 60

        var visualTime = VisualMusicalTime()
        visualTime.timeSignature = ._4_4
        visualTime.tempo = tempo
        visualTime.pixelsPerSecond = 60

        let visualMeasure = try #require(visualTime.visualPulse)

        let barDuration: TimeInterval = visualMeasure.measure.duration(pulse: .bar)
        let beatDuration: TimeInterval = visualMeasure.measure.duration(pulse: .beat)
        let subdivisionDuration: TimeInterval = visualMeasure.measure.duration(pulse: .subdivision)

        Log.debug("tempo", tempo, "barDuration", barDuration, "beatDuration", beatDuration, "subdivisionDuration", subdivisionDuration)

        if time == 0 {
            #expect(visualTime.timeToNearest(pulse: .beat, at: time, direction: .forward) == beatDuration)
            #expect(visualTime.timeToNearest(pulse: .beat, at: time, direction: .backward) == -beatDuration)
            #expect(visualTime.timeToNearest(pulse: .bar, at: time, direction: .forward) == barDuration)
            #expect(visualTime.timeToNearest(pulse: .bar, at: time, direction: .backward) == -barDuration)
            #expect(visualTime.timeToNearest(pulse: .subdivision, at: time, direction: .forward) == subdivisionDuration)
            #expect(visualTime.timeToNearest(pulse: .subdivision, at: time, direction: .backward) == -subdivisionDuration)

        } else {
            #expect(visualTime.timeToNearest(pulse: .beat, at: time, direction: .forward) == beatDuration - time)
            #expect(visualTime.timeToNearest(pulse: .beat, at: time, direction: .backward) == -time)

            #expect(visualTime.timeToNearest(pulse: .bar, at: time, direction: .forward) == barDuration - time)
            #expect(visualTime.timeToNearest(pulse: .bar, at: time, direction: .backward) == -time)

            #expect(visualTime.timeToNearest(pulse: .subdivision, at: time, direction: .forward) == subdivisionDuration)
            #expect(visualTime.timeToNearest(pulse: .subdivision, at: time, direction: .backward) == -subdivisionDuration)
        }
    }

    @Test func timeToNearest2() throws {
//        #expect(MusicalMeasure.Pulse.bar.duration(timeSignature: ._4_4, tempo: 60) == 4)
//        #expect(Pulse.beat.duration(timeSignature: ._4_4, tempo: 60) == 1)
//        #expect(Pulse.subdivision.duration(timeSignature: ._4_4, tempo: 60) == 0.25)
//
//        #expect(Pulse.bar.duration(timeSignature: ._4_4, tempo: 120) == 2)
//        #expect(Pulse.beat.duration(timeSignature: ._4_4, tempo: 120) == 0.5)
//        #expect(Pulse.subdivision.duration(timeSignature: ._4_4, tempo: 120) == 0.125)
    }
}
