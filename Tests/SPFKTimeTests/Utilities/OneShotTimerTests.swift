// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-time

@testable import SPFKTime
import Testing

@Suite("OneShotTimer")
struct OneShotTimerTests {
    @Test func initialState() {
        let timer = OneShotTimer(timeInterval: 0.1)

        #expect(timer.state == .suspended)
        #expect(timer.timeInterval == 0.1)
    }

    @Test func resumeTransitionsToResumed() {
        let timer = OneShotTimer(timeInterval: 1.0)
        timer.resume()

        #expect(timer.state == .resumed)

        timer.dispose()
    }

    @Test func suspendTransitionsToSuspended() {
        let timer = OneShotTimer(timeInterval: 1.0)
        timer.resume()
        timer.suspend()

        #expect(timer.state == .suspended)
    }

    @Test func disposeTransitionsToSuspended() {
        let timer = OneShotTimer(timeInterval: 1.0)
        timer.resume()
        timer.dispose()

        #expect(timer.state == .suspended)
        #expect(timer.eventHandler == nil)
    }

    @Test func firesOnceAfterInterval() async throws {
        let counter = Counter()
        let timer = OneShotTimer(timeInterval: 0.01, eventHandler: {
            counter.increment()
        })

        timer.resume()

        try await Task.sleep(for: .milliseconds(100))

        timer.dispose()

        #expect(counter.value == 1)
    }

    @Test func suspendBeforeFiringPreventsCallback() async throws {
        let counter = Counter()
        let timer = OneShotTimer(timeInterval: 0.5, eventHandler: {
            counter.increment()
        })

        timer.resume()
        timer.suspend()

        try await Task.sleep(for: .milliseconds(100))

        #expect(counter.value == 0)
    }

    @Test func timerTypeProperty() {
        let timer = OneShotTimer(timeInterval: 0.5, qos: .userInitiated)
        let expected: TimerFactory.TimerType = .oneShot(timeInterval: 0.5, qos: .userInitiated)
        #expect(timer.timerType == expected)
        timer.dispose()
    }

    @Test func fpsComputedProperty() {
        let timer = OneShotTimer(timeInterval: 1.0 / 60.0)
        #expect(timer.fps > 59.0)
        #expect(timer.fps < 61.0)
        timer.dispose()
    }
}
