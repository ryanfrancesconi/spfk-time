@testable import SPFKTime
import SPFKUtils
import Testing
import SwiftTimecode

@Suite("TimerFactory")
struct TimerTests {
    @Test func typeEquatable() {
        let timerType1: TimerFactory.TimerType = .repeating(timeInterval: TimerFactory.fps30, qos: .default, leeway: 10)
        let timerType2: TimerFactory.TimerType = .repeating(timeInterval: TimerFactory.fps60, qos: .default, leeway: 10)

        #expect(timerType1 != timerType2)
    }

    @Test func sameTypesAreEqual() {
        let a: TimerFactory.TimerType = .basic(timeInterval: 0.5, leeway: 100)
        let b: TimerFactory.TimerType = .basic(timeInterval: 0.5, leeway: 100)
        #expect(a == b)
    }

    @Test func differentKindsAreNotEqual() {
        let basic: TimerFactory.TimerType = .basic(timeInterval: TimerFactory.fps30)
        let oneShot: TimerFactory.TimerType = .oneShot(timeInterval: TimerFactory.fps30)
        #expect(basic != oneShot)
    }

    @Test func fps60Constant() {
        #expect(TimerFactory.fps60 > 0)
        #expect(TimerFactory.fps60 < 1.0 / 59.0)
    }

    @Test func fps30Constant() {
        #expect(TimerFactory.fps30 > 0)
        #expect(TimerFactory.fps30 < 1.0 / 29.0)
    }

    @Test func createBasicTimer() {
        let timer = TimerFactory.createTimer(.basic(timeInterval: 0.1, leeway: 50))
        #expect(timer is BasicTimer)
        #expect(timer.timeInterval == 0.1)
        timer.dispose()
    }

    @Test func createOneShotTimer() {
        let timer = TimerFactory.createTimer(.oneShot(timeInterval: 0.2, qos: .userInitiated))
        #expect(timer is OneShotTimer)
        #expect(timer.timeInterval == 0.2)
        timer.dispose()
    }

    @Test func createRepeatingTimer() {
        let timer = TimerFactory.createTimer(.repeating(timeInterval: 0.3, qos: .utility, leeway: 25))
        #expect(timer is RepeatingTimer)
        #expect(timer.timeInterval == 0.3)
        timer.dispose()
    }

    // MARK: - TimerState

    @Test func timerStateCases() {
        let suspended = TimerState.suspended
        let resumed = TimerState.resumed
        #expect(suspended != resumed)
    }
}
