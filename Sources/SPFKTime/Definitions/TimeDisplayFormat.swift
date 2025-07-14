import Foundation

public enum TimeDisplayFormat: String, Codable, CaseIterable {
    // IAC: must match what is in the config.js of the client extension
    case timecode
    case seconds
    
    public init?(title: String) {
        for item in Self.allCases where item.title == title {
            self = item
            return
        }
        
        return nil
    }

    public var title: String {
        switch self {
        case .timecode:
            return "Timecode"

        case .seconds:
            return "Seconds"
        }
    }
}
