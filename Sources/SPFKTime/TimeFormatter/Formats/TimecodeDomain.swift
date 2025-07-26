
import Foundation
import TimecodeKit

/// How many subframes per frame.
/// There is no industry standard; Pro Tools uses 100, Logic Pro and Cubase use 80.
/// Most DAWs only support the SMPTE standard of a 24 hour clock:
/// (00:00:00:00 ... 23:59:59:XX where XX is 1 frame less than 24 hours)
/// However some DAWs like Cubase support Days as a timecode component.
public struct TimecodeDomain {
    // MARK: - Internal Properties

    /// Flag that determines if subframes are displayed when accessing `.stringValue`
    public var showSubFrames: Bool = false

    var stringFormat: Timecode.StringFormat {
        showSubFrames ? [.showSubFrames] : []
    }

    public private(set) var properties = Timecode.Properties(rate: Self.defaultFrameRate)

    public var frameRate: TimecodeFrameRate { properties.frameRate }

    /// The real time duration one second of current timecode
    public private(set) var timecodeSecond: TimeInterval = 1

    public private(set) var frameRateMultiplier: Double = 1

    var isFractional: Bool {
        frameRate.isDrop ||
            frameRate == .fps23_976 ||
            frameRate == .fps24_98 ||
            frameRate == .fps29_97 ||
            frameRate == .fps47_952 ||
            frameRate == .fps59_94 ||
            frameRate == .fps119_88
    }

    // MARK: - Init

    init(showSubFrames: Bool = false) {
        self.showSubFrames = showSubFrames

        masterTimecode = Timecode(
            .zero,
            at: Self.defaultFrameRate,
            base: properties.subFramesBase,
            limit: properties.upperLimit
        )

        properties.frameRate = Self.defaultFrameRate
        updateProperties()
    }

    private mutating func updateProperties() {
        let hour = Timecode.Components(h: 1)

        guard let oneHourTimecode = try? Timecode(.components(hour), at: frameRate) else { return }

        var sec: TimeInterval = oneHourTimecode.realTimeValue / 3600

        if frameRate.isDrop {
            sec /= 1.001
        }

        self.timecodeSecond = sec
        self.frameRateMultiplier = isFractional ? 1.001 : 1
    }

    // MARK: - Frame Rate

    public static var defaultFrameRate: TimecodeFrameRate = .fps24

    /// Internal: Set frame rate.
    /// Returns `true` if the frame rate was successfully set and master timecode was updated to reflect the new frame rate.
    ///
    /// - Parameters:
    ///   - newFrameRate: New frame rate
    ///   - preservingValuesIfPossible: If `true`, attempt to preserve individual timecode values if possible, otherwise convert timecode to its equivalent position. If `false`, always convert timecode to its equivalent position.
    ///   - clampPositionToStartTimecode: If master timecode is converted due to the frame rate change, ensure that it is not prior to `startTimecode`.
    mutating func setFrameRate(
        to newFrameRate: TimecodeFrameRate,
        preservingValuesIfPossible: Bool,
        clampPositionToStartTimecode: Bool
    ) -> Bool {
        guard newFrameRate != properties.frameRate else { return true }

        properties.frameRate = newFrameRate
        updateProperties()

        // update start timecode to reflect new frame rate
        if let startTimecode {
            do {
                if preservingValuesIfPossible {
                    // attempt to preserve timecode values (Pro Tools/Logic behavior)
                    if try setStartTimecode(preservingValuesFrom: startTimecode,
                                            clampPositionToStartTimecode: clampPositionToStartTimecode) {
                        return true
                    }
                } else {
                    // always convert entire timecode (Cubase/Nuendo behavior)
                    if try setStartTimecode(convertingFrom: startTimecode,
                                            clampPositionToStartTimecode: clampPositionToStartTimecode) {
                        return true
                    }
                }
            } catch {
                return false
            }
        }

        // update master timecode to reflect new frame rate
        if setTimecode(
            literally: masterTimecode,
            clampPositionToStartTimecode: clampPositionToStartTimecode
        ) {
            return true
        }

        return false
    }

    // MARK: - Timecode

    // guaranteed to be set during init()
    public private(set) var masterTimecode: Timecode

    /// Sets the timecode directly, not applying any `startTimecode` offset and without converting from different frame rate or base settings.
    /// Returns `true` if the value was set without alteration due to validation.
    ///
    /// This should only be called internally when the timecode being passed in is guaranteed to match the frame rate and base settings of this `TimecodeDomain` instance.
    ///
    /// Internal. Should only be called from a `TransportTime` method.
    private mutating func setTimecode(
        literally timecode: Timecode,
        clampPositionToStartTimecode: Bool
    ) -> Bool {
        var valid = true
        var timecode = timecode

        // validate
        if clampPositionToStartTimecode,
           let startTimecode,
           timecode < startTimecode {
            timecode = startTimecode
            valid = false
        }

        // update master timecode
        masterTimecode = timecode

        return valid
    }

    /// Sets the timecode directly, not applying any `startTimecode` offset.
    /// Returns `true` if the value was set without alteration due to validation.
    ///
    /// Internal. Should only be called from a `TransportTime` method.
    mutating func setTimecode(literallyConvertingFrom timecode: Timecode,
                              clampPositionToStartTimecode: Bool) -> Bool {
        let validation: Timecode.ValidationRule = clampPositionToStartTimecode ? .clamping : .wrapping

        guard let convertedTC = try? formNewTimecode(convertingFrom: timecode, by: validation) else { return false }

        return setTimecode(literally: convertedTC,
                           clampPositionToStartTimecode: clampPositionToStartTimecode)
    }

    /// Sets the `seconds` value directly as its equivalent timecode, not applying any `startTimecode` offset.
    /// Returns `true` if the value was set without alteration due to validation.
    ///
    /// Internal. Should only be called from a `TransportTime` method.
    mutating func setTimecode(literally seconds: TimeInterval,
                              clampPositionToStartTimecode: Bool) throws -> Bool {
        let seconds = seconds.clamped(to: 0...)

        var newTC: Timecode

        if masterTimecode.frameRate != properties.frameRate {
            newTC = formNewTimecode(wrappingRealTimeSeconds: seconds)

        } else {
            newTC = masterTimecode
            newTC.set(.realTime(seconds: seconds), by: .wrapping)
        }

        return setTimecode(literally: newTC, clampPositionToStartTimecode: clampPositionToStartTimecode)
    }

    /// Sets timecode to the equivalent timecode by offsetting `seconds` by the `startTimecode`.
    /// Returns `true` if the value was set without alteration due to validation.
    ///
    /// Internal. Should only be called from a `TransportTime` method.
    mutating func setTimecode(elapsedTime seconds: TimeInterval) throws -> Bool {
        let startTime = startTimecode?.realTimeValue ?? 0.0
        return try setTimecode(literally: startTime + seconds,
                               clampPositionToStartTimecode: false)
    }

    // MARK: - Start Timecode

    public private(set) var startTimecode: Timecode?

    /// Internal. Should only be called from a `TransportTime` method.
    /// Returns `true` if the start timecode was set without needing to alter master timecode due to validation.
    mutating func setStartTimecode(seconds: TimeInterval?,
                                   clampPositionToStartTimecode: Bool) throws -> Bool {
        guard let seconds else {
            startTimecode = nil
            return true
        }

        startTimecode = formNewTimecode(wrappingRealTimeSeconds: seconds)

        if clampPositionToStartTimecode {
            return clampMasterTimecode()
        }

        return true
    }

    /// Internal. Should only be called from a `TransportTime` method.
    /// Returns `true` if the start timecode was set without needing to alter master timecode due to validation.
    mutating func setStartTimecode(convertingFrom tc: Timecode?,
                                   clampPositionToStartTimecode: Bool) throws -> Bool {
        guard let tc else {
            startTimecode = nil
            return true
        }

        let validation: Timecode.ValidationRule = clampPositionToStartTimecode ? .clamping : .wrapping

        let newTC = try formNewTimecode(convertingFrom: tc, by: validation)

        startTimecode = newTC

        if clampPositionToStartTimecode {
            return clampMasterTimecode()
        }

        return true
    }

    /// Internal. Should only be called from a `TransportTime` method.
    /// Returns `true` if the start timecode was set without needing to alter master timecode due to validation.
    mutating func setStartTimecode(preservingValuesFrom tc: Timecode?,
                                   clampPositionToStartTimecode: Bool) throws -> Bool {
        guard let tc else {
            startTimecode = nil
            return true
        }

        let validation: Timecode.ValidationRule = clampPositionToStartTimecode ? .clamping : .wrapping

        let newTC = try formNewTimecode(preservingValuesFrom: tc, by: validation)
        startTimecode = newTC

        if clampPositionToStartTimecode {
            return clampMasterTimecode()
        }

        return true
    }

    /// Internal. If master timecode is prior to start timecode, it will be clamped.
    /// Returns `true` if clamping occurred.
    fileprivate mutating func clampMasterTimecode() -> Bool {
        if let startTC = startTimecode,
           startTC > masterTimecode {
            masterTimecode = startTC
            return false
        }

        return true
    }

    // MARK: - Accessors

    /// Returns the elapsed time from `startTimecode` to current timecode, expressed as a real-time value.
    ///
    /// Internal. Should only be called from a TransportTime method.
    func calculateElapsedRealTime() -> TimeInterval {
        if let startTC = startTimecode {
            return masterTimecode.realTimeValue - startTC.realTimeValue
        } else {
            return masterTimecode.realTimeValue
        }
    }
}

// MARK: - Timecode Factory Methods

extension TimecodeDomain {
    /// Returns a `Timecode` object with local base settings applied, at default 00:00:00:00.
    public func formNewTimecode() -> Timecode {
        Timecode(
            .zero,
            using: properties
        )
    }

    /// Returns a `Timecode` object with local base settings applied by converting from another `Timecode` instance, and will be converted.
    public func formNewTimecode(convertingFrom other: Timecode, by validation: Timecode.ValidationRule = .clamping) throws -> Timecode {
        // avoid converting to realTimeValue if possible
        guard properties != other.properties else {
            return formNewTimecode(components: other.components, by: validation)
        }

        let realTimeValue = other.realTimeValue

        return formNewTimecode(wrappingRealTimeSeconds: realTimeValue)
    }

    /// Returns a `Timecode` object with local base settings applied by converting from another `Timecode` instance, preserving literal timecode values if possible. If values are not expressible in the new frame rate, the entire timecode will be converted.
    public func formNewTimecode(preservingValuesFrom other: Timecode, by validation: Timecode.ValidationRule = .clamping) throws -> Timecode {
        do {
            let newTC = try Timecode(
                .components(other.components),
                using: properties
            )
            return newTC

        } catch {
            return try formNewTimecode(convertingFrom: other, by: validation)
        }
    }

    /// Returns a `Timecode` object with local base settings applied, from a string.
    public func formNewTimecode(string: String) throws -> Timecode {
        try Timecode(
            .string(string),
            using: properties
        )
    }

    /// Returns a `Timecode` object with local base settings applied, from raw timecode components.
    public func formNewTimecode(components: Timecode.Components, by validation: Timecode.ValidationRule = .clamping) -> Timecode {
        Timecode(
            .components(components),
            using: properties,
            by: validation
        )
    }

    /// Returns a `Timecode` object with local base settings applied, from seconds.
    public func formNewTimecode(wrappingRealTimeSeconds seconds: TimeInterval) -> Timecode {
        Timecode(
            .realTime(seconds: seconds),
            using: properties,
            by: .wrapping
        )
    }

    /// Returns a `Timecode` object offset from current `startTimecode`, allowing for negative results.
    /// NOTE: Use this sparingly, as timecode is not a format that is usually displayed as a negative.
    public func formNewSignedTimecode(seconds: TimeInterval,
                                      offsetFromStart: Bool = false) -> SignedTimecode {
        let secs = (offsetFromStart ? startTimecode?.realTimeValue ?? 0.0 : 0.0) + seconds
        let sign: FloatingPointSign = secs < 0 ? .minus : .plus

        let timecode = formNewTimecode(wrappingRealTimeSeconds: abs(secs))

        return .init(timecode: timecode, sign: sign)
    }
}
