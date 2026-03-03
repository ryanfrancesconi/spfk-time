import CoreMedia
import Foundation
@testable import SPFKTime
import SwiftTimecode
import Testing

@Suite("Timecode Properties")
struct TimecodePropertiesTests {
    // MARK: - roundedValue

    @Test("roundedValue returns self when no subframes")
    func roundedValueNoSubframes() throws {
        let tc = try Timecode(.components(h: 1, m: 0, s: 0, f: 10), at: .fps24)
        #expect(tc.roundedValue == tc)
    }

    @Test("roundedValue rounds up when subframes present")
    func roundedValueWithSubframes() throws {
        let tc = try Timecode(.components(h: 1, m: 0, s: 0, f: 10, sf: 50),
                              at: .fps24, base: .max100SubFrames)
        let rounded = tc.roundedValue
        #expect(rounded.subFrames == 0)
        #expect(rounded.frames == 11)
    }

    // MARK: - cmTime

    @Test("cmTime converts to CMTime correctly")
    func cmTimeConversion() throws {
        let tc = try Timecode(.components(h: 0, m: 0, s: 1, f: 0), at: .fps24)
        let cm = tc.cmTime
        #expect(abs(cm.seconds - 1.0) < 0.001)
    }

    @Test("cmTime at zero is zero seconds")
    func cmTimeZero() {
        let tc = Timecode(.zero, at: .fps24)
        let cm = tc.cmTime
        #expect(cm.seconds == 0.0)
    }

    // MARK: - zero

    @Test("zero returns timecode at same frame rate")
    func zeroProperty() throws {
        let tc = try Timecode(.components(h: 1, m: 30, s: 0, f: 0), at: .fps25)
        let z = tc.zero
        #expect(z.frameRate == .fps25)
        #expect(z.frameCount.wholeFrames == 0)
    }

    // MARK: - roundUpToNextFrame

    @Test("roundUpToNextFrame with no subframes returns self")
    func roundUpNoSubframes() throws {
        let tc = try Timecode(.components(h: 0, m: 0, s: 0, f: 5), at: .fps24)
        let result = try tc.roundUpToNextFrame()
        #expect(result == tc)
    }

    @Test("roundUpToNextFrame increments frame and clears subframes")
    func roundUpWithSubframes() throws {
        let tc = try Timecode(.components(h: 0, m: 0, s: 0, f: 5, sf: 25),
                              at: .fps24, base: .max100SubFrames)
        let result = try tc.roundUpToNextFrame()
        #expect(result.frames == 6)
        #expect(result.subFrames == 0)
    }
}
