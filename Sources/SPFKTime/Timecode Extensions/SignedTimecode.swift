import TimecodeKit

/// Type wrapping `Timecode` that supports signed (positive or negative) timecode string expression.
public struct SignedTimecode {
    public var timecode: Timecode
    public var sign: FloatingPointSign
    
    public init(timecode: Timecode,
                sign: FloatingPointSign = .plus) {
        self.timecode = timecode
        self.sign = sign
    }
    
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
