import CoreGraphics
import Foundation

/// Constants for PassKit image dimensions
public enum PassKitConstants {
    // Aspect ratio for the PassKit pass itself
    // Measured from screenshots of passes in Apple Wallet (direct from device). macOS preview of .pkpass files does not match (it is ~0.784)
    public static let passAspectRatio: CGFloat = 0.715

    // Strip image dimensions (for storeCard passes)
    // See https://help.passkit.com/en/articles/2214902-what-are-the-optimum-image-sizes
    public enum StripImage {
        public static let width: CGFloat = 1125.0
        public static let height: CGFloat = 432.0
        public static let aspectRatio: CGFloat = width / height
    }

    // Background image dimensions (for eventTicket passes)
    public enum BackgroundImage {
        public static let width: CGFloat = 112.0
        public static let height: CGFloat = 142.0
    }

    // Logo image dimensions (for all pass types)
    // see https://developer.apple.com/library/archive/documentation/UserExperience/Conceptual/PassKit_PG/Creating.html#//apple_ref/doc/uid/TP40012195-CH4-SW1
    public enum LogoImage {
        public static let width: CGFloat = 160.0
        public static let height: CGFloat = 50.0
        public static let aspectRatio: CGFloat = width / height
    }

    // Thumbnail image dimensions
    public enum ThumbnailImage {
        public static let width: CGFloat = 90.0
        public static let height: CGFloat = width
    }

    // Icon image dimensions. See https://developer.apple.com/design/human-interface-guidelines/wallet
    public enum IconImage {
        public static let width: CGFloat = 38.0
        public static let height: CGFloat = width
    }
}
