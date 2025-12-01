
import Foundation

public protocol TimerModel: AnyObject {
    var eventHandler: (() -> Void)? { get set }

    var state: TimerState { get }

    /// The interval that the timer is firing
    var timeInterval: TimeInterval { get }

    func resume()

    func suspend()

    func dispose()
}

extension TimerModel {
    public var fps: Double {
        1 / timeInterval
    }
}
