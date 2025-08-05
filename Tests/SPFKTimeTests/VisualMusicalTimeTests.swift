

@testable import SPFKTime
import Testing

struct VisualMusicalTimeTests {
    @Test func updateValues1() async throws {
        var visualTime = VisualMusicalTime()

        visualTime.timeSignature = ._4_4
        visualTime.tempo = 60
        visualTime.pixelsPerSecond = 60

        #expect(visualTime.visualMeasure?.pixelsPerBar == 240)
        #expect(visualTime.visualMeasure?.pixelsPerBeat == 60)
        #expect(visualTime.visualMeasure?.pixelsPerSubdivision == 15)
    }

    @Test func updateValues2() async throws {
        var visualTime = VisualMusicalTime()
        visualTime.timeSignature = ._4_4
        visualTime.tempo = 120
        visualTime.pixelsPerSecond = 30

        #expect(visualTime.visualMeasure?.pixelsPerBar == 60)
        #expect(visualTime.visualMeasure?.pixelsPerBeat == 15)
        #expect(visualTime.visualMeasure?.pixelsPerSubdivision == 3.75)
    }
}
