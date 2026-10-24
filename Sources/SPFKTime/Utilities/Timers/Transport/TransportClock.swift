// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-time

import Foundation

/// The transport's source position as a function of host time: `(host − origin) × rate`, held at
/// the start position until the start, and folded at each scheduled rate change so the position
/// stays continuous and only its slope moves.
///
/// Host times are seconds on the host clock (`AVAudioTime.seconds(forHostTime:)`).
public struct TransportClock: Equatable, Sendable {
    public struct RateChange: Equatable, Sendable {
        public let hostTime: TimeInterval
        public let rate: Double
    }

    /// The host time at which the position would be zero at the current rate.
    public private(set) var origin: TimeInterval

    /// Source seconds per host second.
    public private(set) var rate: Double

    /// The position reported until ``startHostTime``.
    public private(set) var startPosition: TimeInterval
    public private(set) var startHostTime: TimeInterval

    /// Rate changes not yet reached, in the order they take effect.
    public private(set) var pendingChanges: [RateChange] = []

    public init(position: TimeInterval = 0, hostTime: TimeInterval, rate: Double = 1) {
        let rate = Self.valid(rate)
        self.rate = rate
        origin = hostTime - position / rate
        startPosition = position
        startHostTime = hostTime
    }

    /// The source position heard at `hostTime`.
    public func position(at hostTime: TimeInterval) -> TimeInterval {
        guard hostTime > startHostTime else { return startPosition }
        return folded(through: hostTime).linearPosition(at: hostTime)
    }

    /// The rate heard at `hostTime`.
    public func rate(at hostTime: TimeInterval) -> Double {
        folded(through: hostTime).rate
    }

    /// The host time at which `position` is heard; the inverse of ``position(at:)`` from the start on.
    public func hostTime(forPosition position: TimeInterval) -> TimeInterval {
        var clock = self

        for change in pendingChanges {
            guard clock.linearPosition(at: change.hostTime) < position else { break }
            clock.fold(at: change.hostTime, rate: change.rate)
        }

        return clock.origin + position / clock.rate
    }

    /// Schedules a new rate, first heard at `hostTime`, after any change already scheduled.
    public mutating func changeRate(to rate: Double, at hostTime: TimeInterval) {
        let hostTime = max(hostTime, pendingChanges.last?.hostTime ?? -.infinity)
        pendingChanges.append(RateChange(hostTime: hostTime, rate: Self.valid(rate)))
    }

    /// Applies every change reached by `hostTime`, returning how many took effect.
    @discardableResult
    public mutating func applyChanges(through hostTime: TimeInterval) -> Int {
        let reached = pendingChanges.prefix { $0.hostTime <= hostTime }.count
        self = folded(through: hostTime)
        return reached
    }

    /// Moves the position to `position` at `hostTime`, at the rate reached by then and keeping the
    /// changes scheduled after it.
    public mutating func reanchor(position: TimeInterval, hostTime: TimeInterval) {
        self = folded(through: hostTime)
        origin = hostTime - position / rate
        startPosition = position
        startHostTime = hostTime
    }

    // MARK: -

    private func linearPosition(at hostTime: TimeInterval) -> TimeInterval {
        (hostTime - origin) * rate
    }

    private func folded(through hostTime: TimeInterval) -> TransportClock {
        var clock = self

        while let change = clock.pendingChanges.first, change.hostTime <= hostTime {
            clock.fold(at: change.hostTime, rate: change.rate)
            clock.pendingChanges.removeFirst()
        }

        return clock
    }

    private mutating func fold(at hostTime: TimeInterval, rate newRate: Double) {
        // A change before the start folds at the start, where the position begins to move.
        let at = max(hostTime, startHostTime)
        let position = linearPosition(at: at)
        rate = newRate
        origin = at - position / newRate
    }

    private static func valid(_ rate: Double) -> Double {
        rate.isFinite && rate > 0 ? rate : 1
    }
}
