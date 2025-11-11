import Foundation

/// Depending on the current pixelsPerSecond, multipliers to space out values in the ruler
///
/// This should ultimately be based on a formula, but manual divisions works and may be slightly more performant
public struct TimelineRulerDrawingScale {
    /// applicable for both real time and timecode
    public var time: CGFloat = 1

    /// bars and beats
    public var musical: CGFloat = 1

    public mutating func update(pixelsPerSecond: Double) {
        switch pixelsPerSecond {
        case ...0.025:
            time = 8192
            musical = 2048
        case ...0.05:
            time = 4096
            musical = 1024
        case ...0.1:
            time = 2048
            musical = 512
        case ...0.2:
            time = 1024
            musical = 512
        case ...0.4:
            time = 512
            musical = 512
        case ...0.6:
            time = 256
            musical = 256
        case ...0.75:
            time = 256
            musical = 256
        case ...1.0:
            time = 128
            musical = 256
        case ...2.0:
            time = 96
            musical = 16
        case ...3.0:
            time = 64
            musical = 8
        case ...5.0:
            time = 32
            musical = 4
        case ...10.0:
            time = 16
            musical = 2
        case ...20.0:
            time = 8
            musical = 1
        case ...30.0:
            time = 4
            musical = 1
        case ...60.0:
            time = 2
            musical = 1
        default:
            time = 1
            musical = 1
        }

        // Log.debug("pixelsPerSecond", pixelsPerSecond, "time", time, "musical", musical)
    }

    public init() {}
}
