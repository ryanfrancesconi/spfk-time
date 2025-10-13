import Foundation

public enum TransportTimerEvent {
    case state(TransportTimerPlayState)
    case time(TimeInterval)
    case complete
}

public enum TransportTimerPlayState {
    case start
    case stop
    case pause
    case resume

    public var isPlaying: Bool {
        self == .start ||
            self == .resume
    }
}
