// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-time

import Foundation

/// Events emitted by ``TransportTimer`` to its event handler.
public enum TransportTimerEvent: Sendable {
    /// A transport state change (start, stop, pause, resume).
    case state(TransportTimerPlayState)

    /// An elapsed-time update fired on each display refresh.
    case time(TimeInterval)

    /// The transport reached the end of its content.
    case complete
}

/// The playback state reported by a ``TransportTimer``.
public enum TransportTimerPlayState: Sendable {
    /// Playback has started from a stopped state.
    case start
    /// Playback has stopped.
    case stop
    /// Playback has been paused (position preserved).
    case pause
    /// Playback has resumed from a paused state.
    case resume

    /// `true` when the transport is actively playing (`.start` or `.resume`).
    public var isPlaying: Bool {
        self == .start || self == .resume
    }
}
