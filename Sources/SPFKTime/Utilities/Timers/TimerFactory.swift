// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-time

import Foundation
import SPFKUtils
import SwiftTimecode

// https://developer.apple.com/library/archive/qa/qa1385/_index.html

/// Factory for creating ``TimerModel`` instances of various types.
public enum TimerFactory {
    /// 60 frames per second
    public static var fps60: TimeInterval {
        TimecodeFrameRate.fps60.frameDurationCMTime.seconds
    }

    /// 30 frames per second
    public static var fps30: TimeInterval {
        TimecodeFrameRate.fps30.frameDurationCMTime.seconds
    }

    /// Describes the kind of timer to create.
    public enum TimerType: Equatable {
        /// A main-thread `NSTimer` wrapper. Leeway is in milliseconds.
        case basic(timeInterval: TimeInterval = fps30,
                   leeway: Int = 100)

        /// A single-fire `DispatchWorkItem` timer.
        case oneShot(timeInterval: TimeInterval = fps30,
                     qos: DispatchQoS = .default)

        /// A `DispatchSourceTimer` that fires repeatedly. Leeway is in milliseconds.
        case repeating(timeInterval: TimeInterval = fps30,
                       qos: DispatchQoS = .default,
                       leeway: Int = 100)
    }

    /// Creates and returns a new timer of the specified type.
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
