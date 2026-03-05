// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-time

import CoreMedia

extension CMTime {
    // MARK: - FCPXML utilities

    /// The CMTime value as a FCPXML time string using the format
    /// "[value]/[timescale]s" or "0s" if the value is zero.
    public var stringValue: String {
        guard value != 0 else {
            return "0s"
        }
        return "\(value)/\(timescale)s"
    }
    
    /// A `CMTime` representing exactly one second.
    public static var one: CMTime {
        CMTime(value: 1, timescale: 1)
    }
}

extension CMTimeScale {
    /// The standard video timescale used by QuickTime and FCPXML (600 ticks per second).
    public static let cmTimeScaleVideo: Self = 600
}
