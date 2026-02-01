
import Foundation
import SPFKAudioBase
import SwiftTimecode

/// An object that manages time display.
///
/// A mechanism for storing and converting time, and generating time display strings.
public struct TimeFormatter {
    public var primaryDomain: TimeDomain

    public var timecode: TimecodeDomain = .init()
    public var realTime: RealTimeDomain = .init()

    // MARK: - Init

    public init(primaryDomain: TimeDomain) {
        self.primaryDomain = primaryDomain
    }
}

// MARK: - Public Update Methods

extension TimeFormatter {
    /// Update from elapsed real-time from zero.
    ///
    /// This will update `realTime` to be this value, and update `timecode` to the corresponding timecode offset from the timecode start time.
    public mutating func update(elapsedTime: TimeInterval) {
        let didSucceed = try? timecode.setTimecode(elapsedTime: elapsedTime)

        if didSucceed == true {
            realTime.update(seconds: elapsedTime)

        } else {
            realTime.update(seconds: timecode.calculateElapsedRealTime())
        }
    }

    /// Update timecode position from a literal (non-offset) timecode value.
    ///
    /// This will update `timecode` with this value if it is valid, and update `realTime` to be the corresponding elapsed time, taking into account the timecode start time.
    public mutating func update(position: Timecode) {
        _ = timecode.setTimecode(
            literallyConvertingFrom: position,
            clampPositionToStartTimecode: true
        )

        realTime.update(seconds: timecode.calculateElapsedRealTime())
    }

    /// Update timecode position from a timecode's equivalent real-time value for greater precision.
    ///
    /// This will update `timecode` with this value if it is valid, and update `realTime` to be the corresponding elapsed time, taking into account the timecode start time.
    public mutating func update(position: TimeInterval) {
        _ = try? timecode.setTimecode(
            literally: position,
            clampPositionToStartTimecode: true
        )

        realTime.update(seconds: timecode.calculateElapsedRealTime())
    }

    /// Update the start time (offset) for timecode domain.
    /// Passing `nil` is the same as passing 0.
    public mutating func update(start: TimeInterval?) {
        _ = try? timecode.setStartTimecode(
            seconds: start,
            clampPositionToStartTimecode: true
        )
    }

    /// Update the start time (offset) for timecode domain.
    /// Passing `nil` is the same as passing 0.
    public mutating func update(start: Timecode?) throws {
        _ = try timecode.setStartTimecode(
            convertingFrom: start,
            clampPositionToStartTimecode: true
        )
    }

    /// Update the frame rate.
    /// The timecode position and start timecode will be converted to the new frame rate if necessary.
    public mutating func update(
        frameRate: TimecodeFrameRate,
        preservingValuesIfPossible: Bool = true
    ) {
        guard timecode.frameRate != frameRate else { return }
        // Log.debug("⏰ frameRate to", frameRate.stringValue)

        _ = timecode.setFrameRate(
            to: frameRate,
            preservingValuesIfPossible: preservingValuesIfPossible,
            clampPositionToStartTimecode: true
        )

        // update current timecode position to reflect elapsed real time
        _ = try? timecode.setTimecode(elapsedTime: realTime.masterSeconds)
    }
}

// MARK: - Public Property Accessors

extension TimeFormatter {
    /// Returns the master time display in the format determined by the `.primaryDomain` property.
    public var primaryString: String {
        switch primaryDomain {
        case .realTime:
            realTime.string(showMilliseconds: true)

        case .timecode:
            timecode.masterTimecode.stringValue()

        // TODO:
        case .musical:
            ""
        }
    }

    /// Returns the master time display in the format determined by the `.primaryDomain` property.
    public func primaryString(seconds: TimeInterval) -> String {
        switch primaryDomain {
        case .realTime:
            RealTimeDomain.string(
                seconds: seconds,
                showHours: .auto,
                showMilliseconds: false
            )

        case .timecode:
            timecode.formNewTimecode(wrappingRealTimeSeconds: seconds).stringValue()

        // TODO:
        case .musical:
            ""
        }
    }
}
