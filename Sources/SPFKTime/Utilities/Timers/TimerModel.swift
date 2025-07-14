
import Foundation

public protocol TimerModel: AnyObject {
    var eventHandler: (() -> Void)? { get set }

    var state: TimerFactory.State { get }

    var timeInterval: TimeInterval { get }

    func resume()

    func suspend()
}

extension TimerModel {
    public var fps: Double {
        1 / timeInterval
    }
}
