import Foundation

public class OneShotTimer: TimerModel {
    public var timerType: TimerFactory.TimerType {
        .oneShot(timeInterval: timeInterval, qos: queue.qos)
    }

    private var pendingRequestWorkItem: DispatchWorkItem?

    private func schedule(after: TimeInterval,
                          _ block: @escaping () -> Void) {
        // Cancel the currently pending item
        pendingRequestWorkItem?.cancel()

        // Wrap our request in a work item
        let requestWorkItem = DispatchWorkItem(block: block)

        pendingRequestWorkItem = requestWorkItem
        queue.asyncAfter(deadline: .now() + after,
                         execute: requestWorkItem)
    }

    public var eventHandler: (() -> Void)?

    public private(set) var state: TimerFactory.State = .suspended

    public private(set) var timeInterval: TimeInterval = 1

    private let queue: DispatchQueue

    public init(timeInterval: TimeInterval,
                qos: DispatchQoS = .default,
                eventHandler: (() -> Void)? = nil) {
        self.timeInterval = timeInterval

        queue = DispatchQueue(label: "com.audiodesigndesk.ADD.OneShotTimer",
                              qos: qos,
                              target: .global())

        self.eventHandler = eventHandler
    }

    public func resume() {
        state = .resumed

        if let eventHandler = eventHandler {
            schedule(after: timeInterval, eventHandler)
        }
    }

    public func suspend() {
        state = .suspended
        pendingRequestWorkItem?.cancel()
        pendingRequestWorkItem = nil
    }

    deinit {
        suspend()
        eventHandler = nil
    }
}
