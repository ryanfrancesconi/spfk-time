import AppKit
import Foundation
import SPFKUtils
import SwiftTimecode

// https://developer.apple.com/library/archive/qa/qa1385/_index.html

public enum TimerFactory {
    /// 60 frames per second
    public static var fps60: TimeInterval {
        TimecodeFrameRate.fps60.frameDurationCMTime.seconds
    }

    /// 30 frames per second
    public static var fps30: TimeInterval {
        TimecodeFrameRate.fps30.frameDurationCMTime.seconds
    }

    public enum TimerType: Equatable {
        /// Leeway in milliseconds
        case basic(timeInterval: TimeInterval = fps30,
                   leeway: Int = 100)

        case oneShot(timeInterval: TimeInterval = fps30,
                     qos: DispatchQoS = .default)

        /// Leeway in milliseconds
        case repeating(timeInterval: TimeInterval = fps30,
                       qos: DispatchQoS = .default,
                       leeway: Int = 100)
    }

    public static func createTimer(_ type: TimerType) -> TimerModel {
        switch type {
        case let .basic(timeInterval, leeway):
            return BasicTimer(timeInterval: timeInterval, leeway: leeway)

        case let .oneShot(timeInterval, qos):
            // no leeway
            return OneShotTimer(timeInterval: timeInterval, qos: qos)

        case let .repeating(timeInterval, qos, leeway):
            return RepeatingTimer(timeInterval: timeInterval, qos: qos, leeway: leeway)
        }
    }
}
