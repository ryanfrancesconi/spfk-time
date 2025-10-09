import Foundation

public enum TransportTimerEvent {
    case state(TransportTimerPlayState)
    case time(TimeInterval)
}

public enum TransportTimerPlayState {
    case start
    case stop
    case pause
    case resume
}
