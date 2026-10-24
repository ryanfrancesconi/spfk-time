// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-time

#if os(macOS)

    import AVFoundation
    import Foundation
    @testable import SPFKTime
    import SPFKUtils
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
        // MARK: - Lifetime

        /// The transport hands its internal timer a handler pointing back at itself. Captured
        /// strongly that is a cycle through `internalTimer`, and a transport dropped without
        /// `dispose()` is never freed.
        @Test func aTransportIsReleasedWithoutDispose() {
            weak var weakTimer: TransportTimer?

            autoreleasepool {
                let timer = TransportTimer(timer: MockTimerModel())
                weakTimer = timer
            }

            #expect(weakTimer == nil, "the transport outlived its last reference")
        }

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
    
        // MARK: - Rate

        /// A host clock the test advances by hand.
        private final class HostClock {
            var seconds: TimeInterval = 1000
            var ticks: UInt64 { AVAudioTime.hostTime(forSeconds: seconds) }
        }

        private func makeTimer() -> (TransportTimer, MockTimerModel, HostClock) {
            let mock = MockTimerModel()
            let timer = TransportTimer(timer: mock)
            let host = HostClock()
            timer.hostClock = { host.ticks }
            return (timer, mock, host)
        }

        @Test func startAtHalfRate() {
            let (timer, mock, host) = makeTimer()
            timer.start(at: 10, hostTime: host.ticks, rate: 0.5)

            host.seconds += 2
            mock.fireTick()

            #expect(abs(timer.currentTime - 11) < 1e-6)
            #expect(timer.rate == 0.5)
        }

        /// The defaults are the timer as it was: position is elapsed time since `hostTime − time`.
        @Test func defaultsReproduceARateOneStart() {
            let (timer, mock, host) = makeTimer()
            let start = host.ticks
            timer.start(at: 3, hostTime: start)

            host.seconds += 1.5
            mock.fireTick()

            #expect(abs(timer.currentTime - 4.5) < 1e-6)
            #expect(abs(AVAudioTime.seconds(forHostTime: timer.avStartTime.hostTime) - (1000 - 3)) < 1e-6)
        }

        @Test func aRetimeIsContinuousAndSendsRetimedOnceWhenItTakesEffect() {
            let (timer, mock, host) = makeTimer()
            var retimed: [Double] = []
            timer.eventHandler = { event in
                if case let .retimed(rate, _) = event { retimed.append(rate) }
            }

            timer.start(at: 0, hostTime: host.ticks)
            timer.retime(rate: 0.5, atHostTime: AVAudioTime.hostTime(forSeconds: 1001))

            host.seconds = 1000.9
            mock.fireTick()
            #expect(retimed.isEmpty)
            #expect(abs(timer.currentTime - 0.9) < 1e-6)

            host.seconds = 1001.2
            mock.fireTick()
            #expect(retimed == [0.5])
            #expect(abs(timer.currentTime - 1.1) < 1e-6)

            host.seconds = 1002
            mock.fireTick()
            #expect(retimed == [0.5])
            #expect(abs(timer.currentTime - 1.5) < 1e-6)
        }

        @Test func aRetimeWhileStoppedIsIgnored() {
            let (timer, _, host) = makeTimer()
            timer.retime(rate: 2, atHostTime: host.ticks)
            #expect(timer.clock.pendingChanges.isEmpty)
        }

        @Test func startAvTimeKeepsTheRate() {
            let (timer, mock, host) = makeTimer()
            timer.start(at: 0, hostTime: host.ticks, rate: 2)
            timer.stop()

            timer.start(avTime: AVAudioTime(hostTime: AVAudioTime.hostTime(forSeconds: 999)))
            mock.fireTick()

            #expect(timer.rate == 2)
            #expect(abs(timer.currentTime - 2) < 1e-6)
        }

        /// A loop's wrap restarts at the rate reached by its time, keeping a change scheduled after it.
        @Test func restartTakesTheRateReachedAndKeepsLaterChanges() {
            let (timer, mock, host) = makeTimer()
            timer.start(at: 0, hostTime: host.ticks)
            timer.retime(rate: 0.5, atHostTime: AVAudioTime.hostTime(forSeconds: 1001))
            timer.retime(rate: 2, atHostTime: AVAudioTime.hostTime(forSeconds: 1004))

            timer.restart(at: 10, hostTime: AVAudioTime.hostTime(forSeconds: 1002))
            #expect(timer.rate == 0.5)

            host.seconds = 1003
            mock.fireTick()
            #expect(abs(timer.currentTime - 10.5) < 1e-6)

            host.seconds = 1005
            mock.fireTick()
            #expect(abs(timer.currentTime - (11 + 2)) < 1e-6)
        }

        @Test func hostTimeForSourceRoundTrips() {
            let (timer, _, host) = makeTimer()
            timer.start(at: 4, hostTime: host.ticks, rate: 0.75)
            timer.retime(rate: 1.5, atHostTime: AVAudioTime.hostTime(forSeconds: 1002))

            for position in stride(from: 4.0, through: 9, by: 0.5) {
                #expect(abs(timer.position(atHostTime: timer.hostTime(forSource: position)) - position) < 1e-6)
            }
        }

        @Test func resumeKeepsTheRate() {
            let (timer, mock, host) = makeTimer()
            timer.start(at: 0, hostTime: host.ticks, rate: 0.5)
            host.seconds += 2
            mock.fireTick()
            timer.pause()

            host.seconds += 10
            timer.resume()
            host.seconds += 2
            mock.fireTick()

            #expect(abs(timer.currentTime - 2) < 1e-6)
        }
    }

#endif
