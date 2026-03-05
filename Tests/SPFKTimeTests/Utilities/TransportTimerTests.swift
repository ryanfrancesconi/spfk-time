import Foundation
@testable import SPFKTime
import Testing

/// A minimal mock that tracks resume/suspend/dispose calls without
/// requiring a display context.
final class MockTimerModel: TimerModel {
    var eventHandler: (() -> Void)?
    private(set) var state: TimerState = .suspended
    var timeInterval: TimeInterval = 1.0 / 60.0

    private(set) var resumeCount = 0
    private(set) var suspendCount = 0
    private(set) var disposeCount = 0

    func resume() {
        guard state == .suspended else { return }
        state = .resumed
        resumeCount += 1
    }

    func suspend() {
        guard state == .resumed else { return }
        state = .suspended
        suspendCount += 1
    }

    func dispose() {
        disposeCount += 1
        eventHandler = nil
    }

    /// Simulate a tick from the display link
    func fireTick() {
        eventHandler?()
    }
}

@Suite("TransportTimer")
struct TransportTimerTests {
    // MARK: - Initial state

    @Test func initialStateIsStopped() {
        let mock = MockTimerModel()
        let timer = TransportTimer(timer: mock)

        #expect(timer.isRunning == false)
        #expect(timer.isPaused == false)
        #expect(timer.currentTime == 0)
    }

    // MARK: - Start

    @Test func startResumesInternalTimer() {
        let mock = MockTimerModel()
        let timer = TransportTimer(timer: mock)

        timer.start(at: 0)

        #expect(mock.state == .resumed)
        #expect(mock.resumeCount == 1)
        #expect(timer.isRunning == true)
    }

    @Test func startSendsStartEvent() {
        let mock = MockTimerModel()
        let timer = TransportTimer(timer: mock)

        var receivedEvents: [TransportTimerPlayState] = []
        timer.eventHandler = { event in
            if case let .state(playState) = event {
                receivedEvents.append(playState)
            }
        }

        timer.start(at: 0)

        #expect(receivedEvents == [.start])
    }

    @Test func startWhileRunningIsIgnored() {
        let mock = MockTimerModel()
        let timer = TransportTimer(timer: mock)

        timer.start(at: 0)
        timer.start(at: 1.0)

        #expect(mock.resumeCount == 1)
    }

    // MARK: - Stop

    @Test func stopSuspendsInternalTimer() {
        let mock = MockTimerModel()
        let timer = TransportTimer(timer: mock)

        timer.start(at: 0)
        timer.stop()

        #expect(mock.state == .suspended)
        #expect(mock.suspendCount == 1)
        #expect(timer.isRunning == false)
    }

    @Test func stopSendsStopEvent() {
        let mock = MockTimerModel()
        let timer = TransportTimer(timer: mock)

        var receivedEvents: [TransportTimerPlayState] = []
        timer.eventHandler = { event in
            if case let .state(playState) = event {
                receivedEvents.append(playState)
            }
        }

        timer.start(at: 0)
        timer.stop()

        #expect(receivedEvents == [.start, .stop])
    }

    @Test func stopWhileStoppedIsIgnored() {
        let mock = MockTimerModel()
        let timer = TransportTimer(timer: mock)

        timer.stop()

        #expect(mock.suspendCount == 0)
    }

    // MARK: - Pause

    @Test func pauseSuspendsAndSetsPausedFlag() {
        let mock = MockTimerModel()
        let timer = TransportTimer(timer: mock)

        timer.start(at: 0)
        timer.pause()

        #expect(timer.isPaused == true)
        #expect(timer.isRunning == false)
        #expect(mock.suspendCount == 1)
    }

    @Test func pauseSendsSinglePauseEvent() {
        let mock = MockTimerModel()
        let timer = TransportTimer(timer: mock)

        var receivedEvents: [TransportTimerPlayState] = []
        timer.eventHandler = { event in
            if case let .state(playState) = event {
                receivedEvents.append(playState)
            }
        }

        timer.start(at: 0)
        timer.pause()

        #expect(receivedEvents == [.start, .pause])
    }

    @Test func pauseWhileStoppedIsIgnored() {
        let mock = MockTimerModel()
        let timer = TransportTimer(timer: mock)

        timer.pause()

        #expect(timer.isPaused == false)
    }

    // MARK: - Resume

    @Test func resumeAfterPauseResumesTimer() {
        let mock = MockTimerModel()
        let timer = TransportTimer(timer: mock)

        timer.start(at: 0)
        timer.pause()
        timer.resume()

        #expect(timer.isPaused == false)
        #expect(timer.isRunning == true)
        #expect(mock.resumeCount == 2) // start + resume
    }

    @Test func resumeSendsSingleResumeEvent() {
        let mock = MockTimerModel()
        let timer = TransportTimer(timer: mock)

        var receivedEvents: [TransportTimerPlayState] = []
        timer.eventHandler = { event in
            if case let .state(playState) = event {
                receivedEvents.append(playState)
            }
        }

        timer.start(at: 0)
        timer.pause()
        timer.resume()

        #expect(receivedEvents == [.start, .pause, .resume])
    }

    @Test func resumeWithoutPauseIsIgnored() {
        let mock = MockTimerModel()
        let timer = TransportTimer(timer: mock)

        timer.start(at: 0)
        timer.resume()

        // Should not have sent a resume event — only start
        #expect(mock.resumeCount == 1)
    }

    // MARK: - Full lifecycle

    @Test func startPauseResumeStopLifecycle() {
        let mock = MockTimerModel()
        let timer = TransportTimer(timer: mock)

        var events: [TransportTimerPlayState] = []
        timer.eventHandler = { event in
            if case let .state(playState) = event {
                events.append(playState)
            }
        }

        timer.start(at: 0)
        #expect(timer.isRunning == true)
        #expect(timer.isPaused == false)

        timer.pause()
        #expect(timer.isRunning == false)
        #expect(timer.isPaused == true)

        timer.resume()
        #expect(timer.isRunning == true)
        #expect(timer.isPaused == false)

        timer.stop()
        #expect(timer.isRunning == false)
        #expect(timer.isPaused == false)

        #expect(events == [.start, .pause, .resume, .stop])
    }

    // MARK: - Timer tick emits time event

    @Test func tickEmitsTimeEvent() {
        let mock = MockTimerModel()
        let timer = TransportTimer(timer: mock)

        var receivedTimeEvent = false
        timer.eventHandler = { event in
            if case .time = event {
                receivedTimeEvent = true
            }
        }

        timer.start(at: 0)
        mock.fireTick()

        #expect(receivedTimeEvent == true)
    }

    @Test func tickUpdatesCurrentTime() {
        let mock = MockTimerModel()
        let timer = TransportTimer(timer: mock)

        timer.start(at: 0)
        mock.fireTick()

        #expect(timer.currentTime >= 0)
    }

    // MARK: - Dispose

    @Test func disposeCallsInternalDispose() {
        let mock = MockTimerModel()
        let timer = TransportTimer(timer: mock)

        timer.start(at: 0)
        timer.dispose()

        #expect(mock.disposeCount == 1)
        #expect(timer.eventHandler == nil)
    }

    // MARK: - FPS

    @Test func fpsDelegatesToInternalTimer() {
        let mock = MockTimerModel()
        mock.timeInterval = 1.0 / 60.0
        let timer = TransportTimer(timer: mock)

        #expect(timer.fps == mock.fps)
    }
}
