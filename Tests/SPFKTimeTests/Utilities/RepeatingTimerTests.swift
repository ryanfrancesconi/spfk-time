import Foundation
@testable import SPFKTime
import Testing

/// Thread-safe counter for testing async timer callbacks
final class Counter: @unchecked Sendable {
    private let lock = NSLock()
    private var _value: Int = 0

    var value: Int {
        lock.lock()
        defer { lock.unlock() }
        return _value
    }

    func increment() {
        lock.lock()
        _value += 1
        lock.unlock()
    }
}

@Suite("RepeatingTimer")
struct RepeatingTimerTests {
    @Test func initialState() {
        let timer = RepeatingTimer(timeInterval: 0.1)

        #expect(timer.state == .suspended)
        #expect(timer.timeInterval == 0.1)
        #expect(timer.leeway == 100)
    }

    @Test func customLeeway() {
        let timer = RepeatingTimer(timeInterval: 0.5, leeway: 25)
        #expect(timer.leeway == 25)
        timer.dispose()
    }

    @Test func resumeTransitionsToResumed() {
        let timer = RepeatingTimer(timeInterval: 0.1)
        timer.resume()

        #expect(timer.state == .resumed)

        timer.dispose()
    }

    @Test func suspendTransitionsToSuspended() {
        let timer = RepeatingTimer(timeInterval: 0.1)
        timer.resume()
        timer.suspend()

        #expect(timer.state == .suspended)

        timer.dispose()
    }

    @Test func resumeWhileResumedIsIgnored() {
        let timer = RepeatingTimer(timeInterval: 0.1)
        timer.resume()
        // This should not crash — that's the main point of RepeatingTimer
        timer.resume()

        #expect(timer.state == .resumed)

        timer.dispose()
    }

    @Test func suspendWhileSuspendedIsIgnored() {
        let timer = RepeatingTimer(timeInterval: 0.1)
        // Should not crash
        timer.suspend()
        #expect(timer.state == .suspended)
        timer.dispose()
    }

    @Test func disposeDoesNotCrash() {
        let timer = RepeatingTimer(timeInterval: 0.1)
        // Dispose while suspended — should not crash
        timer.dispose()
    }

    @Test func disposeWhileResumedDoesNotCrash() {
        let timer = RepeatingTimer(timeInterval: 0.1)
        timer.resume()
        timer.dispose()
    }

    @Test func timerTypeProperty() {
        let timer = RepeatingTimer(timeInterval: 0.5, qos: .userInteractive, leeway: 200)
        let expected: TimerFactory.TimerType = .repeating(timeInterval: 0.5, qos: .userInteractive, leeway: 200)
        #expect(timer.timerType == expected)
        timer.dispose()
    }

    @Test func eventHandlerFiresRepeatedly() async throws {
        let counter = Counter()
        let timer = RepeatingTimer(timeInterval: 0.01, leeway: 0)

        timer.eventHandler = {
            counter.increment()
        }

        timer.resume()

        try await Task.sleep(for: .milliseconds(200))

        timer.dispose()

        #expect(counter.value > 1)
    }

    @Test func settingEventHandlerAfterInit() async throws {
        let counter = Counter()
        let timer = RepeatingTimer(timeInterval: 0.01, leeway: 0)

        timer.eventHandler = {
            counter.increment()
        }

        timer.resume()

        try await Task.sleep(for: .milliseconds(200))

        timer.dispose()

        #expect(counter.value > 1)
    }

    @Test func fpsComputedProperty() {
        let timer = RepeatingTimer(timeInterval: 1.0 / 30.0)
        #expect(timer.fps > 29.0)
        #expect(timer.fps < 31.0)
        timer.dispose()
    }
}
