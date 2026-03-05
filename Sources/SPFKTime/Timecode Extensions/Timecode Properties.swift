// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-time

import CoreMedia
import SwiftTimecode

extension Timecode {
    /// Rounds up to the next whole frame if subframes are present, otherwise returns self.
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

    /// This `Timecode` expressed as a `CMTime` object.
    public var cmTime: CMTime {
        CMTime(seconds: realTimeValue,
               preferredTimescale: frameRate.frameDurationCMTime.timescale)
    }

    /// A zero timecode (`00:00:00:00`) at this instance's frame rate.
    public var zero: Timecode {
        .init(.zero, at: frameRate)
    }
}

extension Timecode {
    /// Rounds up to the next whole frame by adding one frame and clearing subframes.
    /// Returns self unchanged if there are no subframes.
    public func roundUpToNextFrame() throws -> Timecode {
        guard subFrames > 0 else { return self }
        var value = try adding(.components(f: 1))
        value.subFrames = 0
        return value
    }
}
