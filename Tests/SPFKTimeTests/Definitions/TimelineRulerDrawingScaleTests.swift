import Foundation
@testable import SPFKTime
import Testing

@Suite("TimelineRulerDrawingScale")
struct TimelineRulerDrawingScaleTests {
    @Test("default values are 1")
    func defaultValues() {
        let scale = TimelineRulerDrawingScale()
        #expect(scale.time == 1)
        #expect(scale.musical == 1)
    }

    @Test("update scales for very zoomed out view")
    func veryZoomedOut() {
        var scale = TimelineRulerDrawingScale()
        scale.update(pixelsPerSecond: 0.02)
        #expect(scale.time == 8192)
        #expect(scale.musical == 2048)
    }

    @Test("update scales for zoomed out view")
    func zoomedOut() {
        var scale = TimelineRulerDrawingScale()
        scale.update(pixelsPerSecond: 0.5)
        #expect(scale.time == 256)
        #expect(scale.musical == 256)
    }

    @Test("update scales for medium zoom")
    func mediumZoom() {
        var scale = TimelineRulerDrawingScale()
        scale.update(pixelsPerSecond: 5.0)
        #expect(scale.time == 32)
        #expect(scale.musical == 4)
    }

    @Test("update scales for zoomed in view")
    func zoomedIn() {
        var scale = TimelineRulerDrawingScale()
        scale.update(pixelsPerSecond: 30.0)
        #expect(scale.time == 4)
        #expect(scale.musical == 1)
    }

    @Test("update scales for very zoomed in view")
    func veryZoomedIn() {
        var scale = TimelineRulerDrawingScale()
        scale.update(pixelsPerSecond: 100.0)
        #expect(scale.time == 1)
        #expect(scale.musical == 1)
    }

    @Test("scales decrease monotonically as pixelsPerSecond increases")
    func monotonicallyDecreasing() {
        var scale = TimelineRulerDrawingScale()
        let zoomLevels: [Double] = [0.01, 0.03, 0.05, 0.1, 0.2, 0.4, 0.6, 0.8, 1.0,
                                     2.0, 3.0, 5.0, 10.0, 20.0, 30.0, 60.0, 100.0]

        var previousTime: CGFloat = .greatestFiniteMagnitude

        for zoom in zoomLevels {
            scale.update(pixelsPerSecond: zoom)
            #expect(scale.time <= previousTime,
                    "time scale should not increase at zoom \(zoom)")
            previousTime = scale.time
        }
    }
}
