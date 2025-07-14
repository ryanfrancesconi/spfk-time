import Foundation

public struct RealTimeDomain {
    // MARK: - Properties
    
    public private(set) var masterSeconds: TimeInterval = 0.0
    
    // MARK: - Init
    
    init() {
        
    }
    
    // MARK: - Internal Methods
    
    mutating func setSeconds(_ seconds: TimeInterval) {
        masterSeconds = seconds
    }
}

// MARK: - Public Methods

extension RealTimeDomain {
    /// Generates a formatted string based on the current `masterSeconds` value.
    public func string(showHours: HoursFormat = .auto,
                       showMilliseconds: Bool = true,
                       offset: TimeInterval = 0.0) -> String {
        Self.string(seconds: masterSeconds + offset,
                    showHours: showHours,
                    showMilliseconds: showMilliseconds)
    }
}
