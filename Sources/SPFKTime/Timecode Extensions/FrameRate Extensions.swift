import Foundation
import SwiftTimecode

extension TimecodeFrameRate {
    public init?(fps: Float, interlaced: Bool = false) {
        guard let videoFrameRate = VideoFrameRate(
            fps: fps,
            interlaced: interlaced) else {
            return nil
        }

        guard let value = videoFrameRate.timecodeFrameRate(drop: false) else {
            return nil
        }

        self = value
    }

    public init?(backwardsCompatibleStringValue value: String) {
        if let frameRate = TimecodeFrameRate(rawValue: value) {
            self = frameRate
        } else if let frameRate = TimecodeFrameRate(stringValue: value) {
            self = frameRate
        } else if let frameRate = TimecodeFrameRate(legacyStringValue: value) {
            self = frameRate

        } else {
            return nil
        }
    }

    public init?(legacyStringValue: String) {
        switch legacyStringValue {
        case "_23_976":
            self = .fps23_976
        case "_24":
            self = .fps24
        case "_24_98":
            self = .fps24_98
        case "_25":
            self = .fps25
        case "_29_97":
            self = .fps29_97
        case "_29_97_drop":
            self = .fps29_97d
        case "_30":
            self = .fps30
        case "_30_drop":
            self = .fps30d
        case "_47_952":
            self = .fps47_952
        case "_48":
            self = .fps48
        case "_50":
            self = .fps50
        case "_59_94":
            self = .fps59_94
        case "_59_94_drop":
            self = .fps59_94d
        case "_60":
            self = .fps60
        case "_60_drop":
            self = .fps60d
        case "_95_904":
            self = .fps95_904
        case "_96":
            self = .fps96
        case "_100":
            self = .fps100
        case "_119_88":
            self = .fps119_88
        case "_119_88_drop":
            self = .fps119_88d
        case "_120":
            self = .fps120
        case "_120_drop":
            self = .fps120d

        default:
            return nil
        }
    }
}

extension TimecodeFrameRate {
    // nominal video rate
    public var floatValue: Float {
        Float(rate.numerator) / Float(rate.denominator)
    }

    public var frameDurationInSeconds: TimeInterval {
        frameDurationCMTime.seconds
    }
}
