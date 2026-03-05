// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-time

import Foundation
@testable import SPFKTime
import SwiftTimecode
import Testing

@Suite("FrameRate Extensions")
struct FrameRateExtensionTests {
    // MARK: - floatValue

    @Test("floatValue returns nominal video rate for integer rates")
    func floatValueIntegerRates() {
        #expect(TimecodeFrameRate.fps24.floatValue == 24.0)
        #expect(TimecodeFrameRate.fps25.floatValue == 25.0)
        #expect(TimecodeFrameRate.fps30.floatValue == 30.0)
        #expect(TimecodeFrameRate.fps48.floatValue == 48.0)
        #expect(TimecodeFrameRate.fps50.floatValue == 50.0)
        #expect(TimecodeFrameRate.fps60.floatValue == 60.0)
    }

    @Test("floatValue returns correct fractional rates")
    func floatValueFractionalRates() {
        // These should be close to their nominal values, not truncated
        #expect(abs(TimecodeFrameRate.fps23_976.floatValue - 23.976) < 0.01)
        #expect(abs(TimecodeFrameRate.fps29_97.floatValue - 29.97) < 0.01)
        #expect(abs(TimecodeFrameRate.fps59_94.floatValue - 59.94) < 0.01)
    }

    // MARK: - frameDurationInSeconds

    @Test("frameDurationInSeconds is reciprocal of frame rate")
    func frameDurationInSeconds() {
        let fps24Duration = TimecodeFrameRate.fps24.frameDurationInSeconds
        #expect(abs(fps24Duration - 1.0 / 24.0) < 0.0001)

        let fps25Duration = TimecodeFrameRate.fps25.frameDurationInSeconds
        #expect(abs(fps25Duration - 1.0 / 25.0) < 0.0001)

        let fps30Duration = TimecodeFrameRate.fps30.frameDurationInSeconds
        #expect(abs(fps30Duration - 1.0 / 30.0) < 0.0001)
    }

    // MARK: - init(fps:)

    @Test("init from fps float value")
    func initFromFps() {
        #expect(TimecodeFrameRate(fps: 24.0) == .fps24)
        #expect(TimecodeFrameRate(fps: 25.0) == .fps25)
        #expect(TimecodeFrameRate(fps: 30.0) == .fps30)
        #expect(TimecodeFrameRate(fps: 60.0) == .fps60)
    }

    @Test("init from invalid fps returns nil")
    func initFromInvalidFps() {
        #expect(TimecodeFrameRate(fps: 0.0) == nil)
        #expect(TimecodeFrameRate(fps: 999.0) == nil)
    }

    // MARK: - backwardsCompatibleStringValue

    @Test("backwardsCompatibleStringValue parses current rawValue")
    func backwardsCompatibleFromRawValue() {
        for rate in TimecodeFrameRate.allCases {
            let parsed = TimecodeFrameRate(backwardsCompatibleStringValue: rate.rawValue)
            #expect(parsed == rate, "Failed to parse rawValue: \(rate.rawValue)")
        }
    }

    @Test("backwardsCompatibleStringValue parses stringValue")
    func backwardsCompatibleFromStringValue() {
        for rate in TimecodeFrameRate.allCases {
            let parsed = TimecodeFrameRate(backwardsCompatibleStringValue: rate.stringValue)
            #expect(parsed == rate, "Failed to parse stringValue: \(rate.stringValue)")
        }
    }

    @Test("backwardsCompatibleStringValue returns nil for garbage")
    func backwardsCompatibleInvalid() {
        #expect(TimecodeFrameRate(backwardsCompatibleStringValue: "garbage") == nil)
        #expect(TimecodeFrameRate(backwardsCompatibleStringValue: "") == nil)
    }

    // MARK: - legacyStringValue

    @Test("legacyStringValue parses known legacy formats")
    func legacyStringValue() {
        #expect(TimecodeFrameRate(legacyStringValue: "_23_976") == .fps23_976)
        #expect(TimecodeFrameRate(legacyStringValue: "_24") == .fps24)
        #expect(TimecodeFrameRate(legacyStringValue: "_25") == .fps25)
        #expect(TimecodeFrameRate(legacyStringValue: "_29_97") == .fps29_97)
        #expect(TimecodeFrameRate(legacyStringValue: "_29_97_drop") == .fps29_97d)
        #expect(TimecodeFrameRate(legacyStringValue: "_30") == .fps30)
        #expect(TimecodeFrameRate(legacyStringValue: "_30_drop") == .fps30d)
        #expect(TimecodeFrameRate(legacyStringValue: "_50") == .fps50)
        #expect(TimecodeFrameRate(legacyStringValue: "_59_94") == .fps59_94)
        #expect(TimecodeFrameRate(legacyStringValue: "_59_94_drop") == .fps59_94d)
        #expect(TimecodeFrameRate(legacyStringValue: "_60") == .fps60)
        #expect(TimecodeFrameRate(legacyStringValue: "_60_drop") == .fps60d)
        #expect(TimecodeFrameRate(legacyStringValue: "_96") == .fps96)
        #expect(TimecodeFrameRate(legacyStringValue: "_100") == .fps100)
        #expect(TimecodeFrameRate(legacyStringValue: "_120") == .fps120)
        #expect(TimecodeFrameRate(legacyStringValue: "_120_drop") == .fps120d)
    }

    @Test("legacyStringValue returns nil for unknown strings")
    func legacyStringValueInvalid() {
        #expect(TimecodeFrameRate(legacyStringValue: "_999") == nil)
        #expect(TimecodeFrameRate(legacyStringValue: "24") == nil)
        #expect(TimecodeFrameRate(legacyStringValue: "") == nil)
    }
}
