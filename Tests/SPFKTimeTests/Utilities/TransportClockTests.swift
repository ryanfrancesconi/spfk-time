// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-time

import Foundation
@testable import SPFKTime
import Testing

@Suite("TransportClock")
struct TransportClockTests {
    @Test func advancesAtItsRateFromTheStart() {
        let clock = TransportClock(position: 10, hostTime: 100, rate: 0.5)

        #expect(clock.position(at: 101) == 10.5)
        #expect(clock.position(at: 104) == 12)
    }

    /// A start placed ahead reports its position until it is heard, never a time before it.
    @Test func holdsTheStartPositionUntilTheStart() {
        let clock = TransportClock(position: 10, hostTime: 100, rate: 2)

        #expect(clock.position(at: 99) == 10)
        #expect(clock.position(at: 100) == 10)
        #expect(clock.position(at: 100.25) == 10.5)
    }

    @Test func rateOneIsElapsedTimeFromTheOrigin() {
        let clock = TransportClock(position: 3, hostTime: 50)

        #expect(clock.origin == 47)
        #expect(clock.position(at: 60) == 13)
    }

    /// The position is continuous through a change, and only the slope moves, at the change.
    @Test func aRateChangeIsContinuousWithTheSlopeChangeAtItsTime() {
        var clock = TransportClock(position: 0, hostTime: 0, rate: 1)
        clock.changeRate(to: 0.5, at: 2)

        let step = 0.001
        var previous = clock.position(at: 0)

        for t in stride(from: step, through: 4, by: step) {
            let position = clock.position(at: t)
            let slope = (position - previous) / step
            let expected = t <= 2 ? 1.0 : (t - step >= 2 ? 0.5 : slope)

            #expect(abs(slope - expected) < 1e-6, "slope \(slope) at \(t)")
            previous = position
        }

        #expect(abs(clock.position(at: 2) - 2) < 1e-12)
        #expect(abs(clock.position(at: 4) - 3) < 1e-12)
        #expect(clock.rate(at: 1.9) == 1)
        #expect(clock.rate(at: 2) == 0.5)
    }

    @Test func applyingAChangeKeepsEveryLaterPosition() {
        var clock = TransportClock(position: 1, hostTime: 0, rate: 1.5)
        clock.changeRate(to: 0.75, at: 1)
        clock.changeRate(to: 2, at: 3)

        let before = stride(from: 0.0, through: 6, by: 0.25).map { clock.position(at: $0) }

        #expect(clock.applyChanges(through: 0.5) == 0)
        #expect(clock.applyChanges(through: 1.5) == 1)
        #expect(clock.rate == 0.75)
        #expect(clock.pendingChanges.count == 1)

        let after = stride(from: 1.5, through: 6, by: 0.25).map { clock.position(at: $0) }
        for (index, position) in after.enumerated() {
            #expect(abs(position - before[index + 6]) < 1e-12)
        }
    }

    @Test func hostTimeIsTheInverseAcrossChanges() {
        var clock = TransportClock(position: 4, hostTime: 10, rate: 0.5)
        clock.changeRate(to: 2, at: 12)

        for t in stride(from: 10.0, through: 16, by: 0.125) {
            let position = clock.position(at: t)
            #expect(abs(clock.hostTime(forPosition: position) - t) < 1e-9, "at \(t)")
        }
    }

    @Test func reanchorKeepsTheRateAndTheScheduledChanges() {
        var clock = TransportClock(position: 0, hostTime: 0, rate: 0.5)
        clock.changeRate(to: 1, at: 20)
        clock.reanchor(position: 2, hostTime: 10)

        #expect(clock.rate == 0.5)
        #expect(clock.position(at: 12) == 3)
        #expect(clock.position(at: 22) == 7 + 2)
    }

    @Test func reanchorTakesTheRateReachedByItsTime() {
        var clock = TransportClock(position: 0, hostTime: 0)
        clock.changeRate(to: 0.5, at: 1)
        clock.reanchor(position: 0, hostTime: 3)

        #expect(clock.rate == 0.5)
        #expect(clock.pendingChanges.isEmpty)
        #expect(clock.position(at: 5) == 1)
    }

    @Test func anInvalidRateIsOne() {
        let clock = TransportClock(position: 0, hostTime: 0, rate: .nan)
        #expect(clock.rate == 1)
    }
}
