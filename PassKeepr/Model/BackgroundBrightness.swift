import SwiftUI

enum BackgroundBrightness: Codable {
    case veryDark
    case normal
    case veryLight

    /// Classifies a 0...1 luminance value (as produced by `UIImage.averageBrightness()` or a
    /// direct RGB brightness calculation) into one of the three buckets used to keep card
    /// chrome (shadows, strokes, overlays) legible against the pass's own colors.
    init(brightness: CGFloat) {
        if brightness < 0.2 {
            self = .veryDark
        } else if brightness > 0.2, brightness < 0.55 {
            self = .normal
        } else {
            self = .veryLight
        }
    }

    var overwriteOpacity: Double {
        switch self {
        case .veryDark: return 0.7
        case .normal: return 0.4
        case .veryLight: return 0.4
        }
    }

    var overwriteOpacityRoundedRectangle: Double {
        switch self {
        case .veryDark: return 0.5
        case .normal: return 0.3
        case .veryLight: return 0.3
        }
    }

    var overwriteForegroundColor: Color {
        switch self {
        case .veryDark: return .gray
        case .normal: return .white
        case .veryLight: return .black
        }
    }
}
