import SwiftUI

enum BackgroundBrightness {
    case veryDark
    case normal
    case veryLight

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
