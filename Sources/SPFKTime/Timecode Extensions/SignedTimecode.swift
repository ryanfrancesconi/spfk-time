// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-time

import SwiftTimecode

/// Type wrapping `Timecode` that supports signed (positive or negative) timecode string expression.
public struct SignedTimecode {
    /// The unsigned timecode value.
    public var timecode: Timecode

    /// Whether this timecode is positive or negative.
    public var sign: FloatingPointSign

    /// Creates a signed timecode.
    ///
    /// - Parameters:
    ///   - timecode: The unsigned timecode value.
    ///   - sign: `.plus` (default) or `.minus`.
    public init(timecode: Timecode,
                sign: FloatingPointSign = .plus) {
        self.timecode = timecode
        self.sign = sign
    }
    
    /// Returns the timecode string prefixed with `"-"` for negative values.
    /// Zero timecodes are always displayed without a sign.
    public func stringValue() -> String {
        // don't show negative sign if timecode is zero
        if timecode.frameCount.doubleValue == 0.0 {
            return timecode.stringValue()
        }
        
        switch sign {
        case .plus:
            return timecode.stringValue()
            
        case .minus:
            return "-" + timecode.stringValue()
        }
    }
}
