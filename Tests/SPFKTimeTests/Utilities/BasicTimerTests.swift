// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-time

@testable import SPFKTime
import Testing

@Suite("BasicTimer")
struct BasicTimerTests {
    @Test func initialState() {
        let timer = BasicTimer(timeInterval: 0.1)

        #expect(timer.state == .suspended)
        #expect(timer.timeInterval == 0.1)
        #expect(timer.leeway == 100)
        #expect(timer.timer == nil)
    }

    @Test func customLeeway() {
        let timer = BasicTimer(timeInterval: 0.5, leeway: 50)
        #expect(timer.leeway == 50)
    }

    @Test @MainActor func resumeTransitionsToResumed() {
        let timer = BasicTimer(timeInterval: 0.1)
        timer.resume()

        #expect(timer.state == .resumed)
        #expect(timer.timer != nil)

        timer.dispose()
    }

    @Test @MainActor func suspendTransitionsToSuspended() {
        let timer = BasicTimer(timeInterval: 0.1)
        timer.resume()
        timer.suspend()

        #expect(timer.state == .suspended)
        #expect(timer.timer == nil)
    }

    @Test @MainActor func resumeWhileResumedIsIgnored() {
        let timer = BasicTimer(timeInterval: 0.1)
        timer.resume()
        let firstTimer = timer.timer

        timer.resume()
        // Should not have replaced the timer
        #expect(timer.timer === firstTimer)

        timer.dispose()
    }

    @Test @MainActor func suspendWhileSuspendedIsIgnored() {
        let timer = BasicTimer(timeInterval: 0.1)
        timer.suspend()
        #expect(timer.state == .suspended)
    }

    @Test @MainActor func disposeInvalidatesTimer() {
        let timer = BasicTimer(timeInterval: 0.1)
        timer.resume()
        timer.dispose()

        #expect(timer.timer == nil)
        #expect(timer.eventHandler == nil)
    }

    @Test @MainActor func handleEventCallsEventHandler() {
        var called = false
        let timer = BasicTimer(timeInterval: 0.1, eventHandler: { called = true })
        timer.handleEvent()
        #expect(called == true)
    }

    @Test func timerTypeProperty() {
        let timer = BasicTimer(timeInterval: 0.5, leeway: 200)
        let expected: TimerFactory.TimerType = .basic(timeInterval: 0.5, leeway: 200)
        #expect(timer.timerType == expected)
    }

    @Test @MainActor func resumeCreatesTimerOnRunLoop() {
        let timer = BasicTimer(timeInterval: 0.1, leeway: 250)
        timer.resume()

        #expect(timer.timer != nil)
        #expect(timer.timer?.isValid == true)

        timer.dispose()
    }

    @Test func fpsComputedProperty() {
        let timer = BasicTimer(timeInterval: 1.0 / 60.0)
        #expect(timer.fps > 59.0)
        #expect(timer.fps < 61.0)
    }
}
