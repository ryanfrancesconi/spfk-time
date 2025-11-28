import CoreMedia
import SwiftTimecode

extension Timecode {
    /// Round down to the frame is subFrames is > 0
    public var roundedValue: Timecode {
        guard subFrames > 0 else { return self }

        var newValue = self

        newValue.subFrames = 0

        let frameCount = Timecode.FrameCount(.frames(newValue.frameCount.wholeFrames + 1),
                                             base: self.frameCount.subFramesBase)

        guard let roundedValue = try? Timecode(.frames(frameCount), at: newValue.frameRate) else {
            return self
        }

        return roundedValue
    }

    /// This `Timecode` expressed as a `CMTime` object
    public var cmTime: CMTime {
        CMTime(seconds: realTimeValue,
               preferredTimescale: frameRate.frameDurationCMTime.timescale)
    }

    /// Convenience to return a 0:00 timecode at the frame rate
    public var zero: Timecode {
        .init(.zero, at: frameRate)
    }
}

extension Timecode {
    public func roundUpToNextFrame() throws -> Timecode {
        guard subFrames > 0 else { return self }
        var value = try adding(.components(f: 1))
        value.subFrames = 0
        return value
    }
}
