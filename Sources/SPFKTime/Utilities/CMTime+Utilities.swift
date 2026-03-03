
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
    
    public static var one: CMTime {
        CMTime(value: 1, timescale: 1)
    }
}

extension CMTimeScale {
    public static let cmTimeScaleVideo: Self = 600
}
