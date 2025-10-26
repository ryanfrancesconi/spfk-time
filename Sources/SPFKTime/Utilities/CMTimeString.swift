
import CoreMedia
import TimecodeKit

// MARK: - Time Conversions for FCPXML

public enum CMTimeString {
    /// Parse a fcpxml based string into a CMTime object
    /// - Parameter string: String to parse, such as 5/24s
    /// - Returns: `CMTime` or `nil`
    public static func parse(string: String) -> CMTime? {
        guard string != "0s" else {
            return .zero
        }

        var string = string.replacingOccurrences(of: "s", with: "")

        var timescale: CMTimeScale = 1

        // if the timescale is 1, the division is optional in the stringValue
        if string.contains("/") {
            let parts = string.components(separatedBy: "/")

            guard let valueString = parts.first,
                  let timeScaleString = parts.last else { return nil }

            guard let timescaleValue = CMTimeScale(timeScaleString) else { return nil }

            string = valueString
            timescale = timescaleValue
        }

        guard let value = CMTimeValue(string) else { return nil }

        return CMTimeMake(value: value, timescale: timescale)
    }
}

// MARK: - Create a new CMTimeString from values

extension CMTimeString {
    public static func create(seconds: TimeInterval,
                              sampleRate: Double,
                              frameRate: TimecodeFrameRate) -> String? {
        let samples = seconds * sampleRate

        guard let timecode = try? Timecode(.samples(samples, sampleRate: sampleRate.int),
                                           at: frameRate) else {
            return nil
        }
        return create(timecode: timecode)
    }

    public static func create(seconds: TimeInterval,
                              frameRate: TimecodeFrameRate) -> String? {
        guard let timecode = try? Timecode(.realTime(seconds: seconds),
                                           at: frameRate) else {
            return nil
        }
        return create(timecode: timecode)
    }

    public static func create(timecode: Timecode, roundToFrame: Bool = false) -> String {
        var timecode = timecode

        if timecode.subFrames > 0,
           roundToFrame,
           let value = try? timecode.roundUpToNextFrame() {
            timecode = value
        }

        let rationalValue = timecode.rationalValue

        guard rationalValue.numerator > 0 else {
            return "0s"
        }

        return "\(rationalValue.numerator)/\(rationalValue.denominator)s"
    }
}
