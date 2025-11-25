import Foundation
import SPFKUtils
import TimecodeKit

extension Timecode {
    /// treats : ; . as delimiters
    public static func parseUnformattedTimecode(
        string: String,
        frameRate: TimecodeFrameRate
    ) -> Timecode.Components? {
        let delimiters = CharacterSet(charactersIn: ":;.")
        let containsDelimiters = string.contains(where: { delimiters.contains($0) })

        var tcc = Timecode.Components(h: 0, m: 0, s: 0, f: 0, sf: 0)

        let components: [String]

        if containsDelimiters ||
            (!containsDelimiters && string.count <= frameRate.numberOfDigits)
        {
            // process as delimited shorthand
            components = string.components(separatedBy: delimiters)

        } else {
            // treat as delimiter-less raw number sequence from right-to-left

            let frRateNumDigits = frameRate.numberOfDigits

            switch frRateNumDigits {
            case 2:
                components = string
                    .split(every: 2, backwards: true)
                    .map { String($0) }

            case 3:
                guard string.count > frRateNumDigits else { return nil }

                let frames = string.suffix(frRateNumDigits).string
                let remainingRange = string.startIndex ... string.index(string.endIndex, offsetBy: -(frRateNumDigits + 1))

                components = string[remainingRange]
                    .split(every: 2, backwards: true)
                    .map { String($0) }
                    + [frames]

            default:
                Log.error("Encountered unhandled number of frames digits in timecode.")
                return nil
            }

            // don't allow more than 4 components because delimiter-less number entry is assuming
            // subframes are not being entered (and the logic below will not parse it correctly)
            if components.count > 4 { return nil }
        }

        switch components.count {
        // 01:00:10:01:11
        case 5:
            tcc.hours = components[0].int ?? 0
            tcc.minutes = components[1].int ?? 0
            tcc.seconds = components[2].int ?? 0
            tcc.frames = components[3].int ?? 0
            tcc.seconds = components[4].int ?? 0

        // 01:00:10:01
        case 4:
            tcc.hours = components[0].int ?? 0
            tcc.minutes = components[1].int ?? 0
            tcc.seconds = components[2].int ?? 0
            tcc.frames = components[3].int ?? 0

        // 01:00:00
        case 3:
            tcc.minutes = components[0].int ?? 0
            tcc.seconds = components[1].int ?? 0
            tcc.frames = components[2].int ?? 0

        // 1:1 = 00:00:01:01
        case 2:
            tcc.seconds = components[0].int ?? 0
            tcc.frames = components[1].int ?? 0

        // 10 = 00:00:00:10
        case 1:
            tcc.frames = components[0].int ?? 0

        default:
            return nil
        }

        return tcc
    }
}
