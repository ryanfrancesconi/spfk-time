
import Foundation

public struct TimelineRulerViewOptions: Equatable {
    public enum DisplayType: Equatable {
        case realTime
        case timecode
        case musical
        case none
    }

    public var topRuler: DisplayType = .realTime
    public var bottomRuler: DisplayType = .musical
    public var drawCenterLine: Bool = false
    public var drawGrid: Bool = false
    public var gridSpacing: CGFloat = 50

    public init(
        topRuler: DisplayType = .realTime,
        bottomRuler: DisplayType = .musical
    ) {
        self.topRuler = topRuler
        self.bottomRuler = bottomRuler
    }
}
