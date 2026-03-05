// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-time

@testable import SPFKTime
import Testing

@Suite("TransportTimerEvent")
struct TransportTimerEventTests {
    // MARK: - TransportTimerPlayState

    @Test func startIsPlaying() {
        #expect(TransportTimerPlayState.start.isPlaying == true)
    }

    @Test func resumeIsPlaying() {
        #expect(TransportTimerPlayState.resume.isPlaying == true)
    }

    @Test func stopIsNotPlaying() {
        #expect(TransportTimerPlayState.stop.isPlaying == false)
    }

    @Test func pauseIsNotPlaying() {
        #expect(TransportTimerPlayState.pause.isPlaying == false)
    }

    // MARK: - TransportTimerEvent cases

    @Test func stateEventCarriesPlayState() {
        let event = TransportTimerEvent.state(.start)
        if case let .state(playState) = event {
            #expect(playState == .start)
        } else {
            Issue.record("Expected .state case")
        }
    }

    @Test func timeEventCarriesInterval() {
        let event = TransportTimerEvent.time(1.5)
        if case let .time(interval) = event {
            #expect(interval == 1.5)
        } else {
            Issue.record("Expected .time case")
        }
    }

    @Test func completeEvent() {
        let event = TransportTimerEvent.complete
        if case .complete = event {
            // pass
        } else {
            Issue.record("Expected .complete case")
        }
    }
}
