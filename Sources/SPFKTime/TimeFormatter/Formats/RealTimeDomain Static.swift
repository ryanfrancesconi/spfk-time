import Foundation
import OTCore

extension RealTimeDomain {
    /// Converts seconds into a time string (real time, not timecode).
    /// Milliseconds are truncated, not rounded.
    ///
    /// - Parameters:
    ///   - seconds: source seconds as a `TimeInterval`
    ///   - showHours: `enable` forces hours to display, `disable` hides hours and allows minutes to be >60, `nil` automatically shows hours if minutes are >60
    ///   - showMilliseconds: enables milliseconds display
    /// - Returns: resulting time format string
    public static func string(
        seconds: TimeInterval,
        showHours: HoursFormat,
        showMilliseconds: Bool = false
    ) -> String {
        let sign = seconds < 0.0 ? "-" : ""
        let absSeconds = seconds < 0.0 ? abs(seconds) : seconds

        let seconds = Int(absSeconds % 60)
        var minutes = Int(absSeconds / 60.0)

        var strHours: String = ""

        let enableHours = {
            strHours = String(minutes / 60) + ":"
            minutes = minutes % 60
        }

        switch showHours {
        case .auto:
            if minutes >= 60 { enableHours() }

        case .enable:
            enableHours()

        case .disable:
            strHours = ""
        }

        let strMinutes = String(format: "%02d", minutes) + ":"

        let strSeconds = String(format: "%02d", seconds)

        let strMilliseconds: String = showMilliseconds
            ? "." + Int(absSeconds * 1000).string(paddedTo: 3).suffix(3)
            : ""

        return sign + strHours + strMinutes + strSeconds + strMilliseconds
    }

    /// Converts a time string (real time, not timecode) into seconds
    /// - Parameter string: an input string such as 00:30.50
    /// - Returns: a `TimeInterval` or `nil` if the parse failed
    public static func parse(string: String) -> TimeInterval? {
        let allowedChars = "0123456789:;.-"

        var string = string.filter {
            allowedChars.contains($0)
        }

        let sign: FloatingPointSign = string.first == "-" ? .minus : .plus

        if sign == .minus {
            string = string.dropFirst().string
        }

        let delimiters = [":", ";"]
        let mult: Double = sign == .minus ? -1 : 1

        for delimiter in delimiters {
            let components = string.components(separatedBy: delimiter)

            if components.count >= 2 {
                return parse(mult: mult, components: components)
            }
        }

        guard let value = TimeInterval(string) else {
            return nil
        }

        return mult * value // assume 1.1234 fractional seconds
    }

    private static func parse(mult: Double, components: [String]) -> TimeInterval? {
        switch components.count {
        // hour 01:00:00.000
        case 3:
            let h = (components[0].double ?? 0) * 3600
            let m = (components[1].double ?? 0) * 60
            let s = (components[2].double ?? 0)
            return mult * (h + m + s)

        // minutes 01:00.000
        case 2:
            let m = (components[0].double ?? 0) * 60
            let s = (components[1].double ?? 0)
            return mult * (m + s)

        default:
            return nil
        }
    }
}
