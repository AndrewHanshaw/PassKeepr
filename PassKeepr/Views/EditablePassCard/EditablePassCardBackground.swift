import SwiftUI

// Combines what used to be two near-identical views (one for iOS 27+, one for earlier versions).
// The only real difference between them was which notch shape to draw for image backgrounds
// (`NotchedRectanglePost27` vs `NotchedRectangle`) - everything else (colors, layered borders,
// shadow, gradient overlay) is identical, so that's the only thing branched on `#available` below.
struct EditablePassCardBackground: View {
    @Environment(\.colorScheme) var colorScheme

    var backgroundImage: Data
    var backgroundColor: UInt
    var backgroundBrightness: BackgroundBrightness
    var isCoupon: Bool

    // Three-section vertical shading:
    // 1. Top: starts at `topOpacity` and fades to transparent by `topFadeEndLocation`.
    // 2. Middle: stays fully transparent until `bottomFadeStartLocation`.
    // 3. Bottom: fades back in (over a longer span than the top fade) up to
    //    `bottomOpacity` at the very bottom edge.
    var topOpacity: Double = 0.04
    var topFadeEndLocation: CGFloat = 0.24
    var bottomFadeStartLocation: CGFloat = 0.45
    var bottomOpacity: Double = 0.085

    var body: some View {
        ZStack {
            backgroundShape
                .fill(shadowColor) // Want to use fill here because there is no strokeborder for the shadow and using .background causes issues with opacity (it uses inverted colors vs the ColorScheme)
                .scaleEffect(0.95, anchor: .bottom)
                .blur(radius: 8)
                .opacity(shadowOpacity)
                .padding(.bottom, -4)

            if backgroundImage != Data() {
                imageBackground
            } else if isCoupon {
                scallopedBackground
            } else {
                plainColorBackground
            }

            gradientOverlay
        }
    }

    private var gradientOverlay: some View {
        LinearGradient(
            stops: [
                .init(color: Color.black.opacity(topOpacity), location: 0),
                .init(color: Color.black.opacity(0), location: topFadeEndLocation),
                .init(color: Color.black.opacity(0), location: bottomFadeStartLocation),
                .init(color: Color.black.opacity(bottomOpacity), location: 1),
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .clipShape(backgroundShape)
        .allowsHitTesting(false)
    }

    // Shared by both the shadow (filled) and the gradient overlay (used as a clip shape) so the
    // two always agree on which silhouette - notched, scalloped, or plain rounded - to use.
    private var backgroundShape: AnyShape {
        if backgroundImage != Data() {
            notchShape()
        } else if isCoupon {
            AnyShape(ScallopedRectangle())
        } else {
            AnyShape(RoundedRectangle(cornerRadius: 10))
        }
    }

    // The two notch shapes aren't the same concrete type, so they can't both be returned from a
    // single `some InsettableShape` function - type-erase to `AnyShape` instead, and apply
    // `insetAmount` directly via the initializer rather than `.inset(by:)`.
    private func notchShape(insetAmount: CGFloat = 0) -> AnyShape {
        if #available(iOS 27.0, *) {
            AnyShape(NotchedRectanglePost27(insetAmount: insetAmount))
        } else {
            AnyShape(NotchedRectangle(insetAmount: insetAmount))
        }
    }

    private var imageBackground: some View {
        ZStack {
            // Border - the same photo, tinted darker/lighter, so the border reads as an edge of the
            // actual image instead of a flat, unrelated color.
            notchShape()
                .fill(Color.clear)
                .background(
                    Image(uiImage: UIImage(data: backgroundImage)!)
                        .resizable()
                        .scaleEffect(1.05)
                        .blur(radius: 6)
                        .overlay(imageBorderTint)
                        .clipShape(notchShape())
                )

            // "Real" background
            notchShape(insetAmount: 2)
                .fill(Color.clear)
                .background(
                    Image(uiImage: UIImage(data: backgroundImage)!)
                        .resizable()
                        .scaleEffect(1.05) // Scale up the image slightly to prevent a semitransparent halo around the image
                        .blur(radius: 6)
                        .clipShape(notchShape(insetAmount: 2))
                )
        }
    }

    private var plainColorBackground: some View {
        ZStack {
            // Border
            RoundedRectangle(cornerRadius: 10)
                .fill(borderColor)

            // "Real" background
            RoundedRectangle(cornerRadius: 10)
                .inset(by: 2)
                .fill(Color(hex: backgroundColor))
        }
    }

    private var scallopedBackground: some View {
        ZStack {
            // Border
            // NOTE: intentionally not using `.strokeBorder` here - stroking this path's ~300 sharp
            // scallop corners self-intersects. Layering two independently-filled copies of the
            // shape sidesteps stroking entirely.
            ScallopedRectangle()
                .fill(borderColor)

            // "Real" background
            ScallopedRectangle(insetAmount: 2)
                .fill(Color(hex: backgroundColor))
        }
        // Render this whole subtree into a single cached texture instead of re-rasterizing the ~300-segment scalloped path
        // on every color change. The shape geometry never changes, only the fill/stroke color
        .drawingGroup()
    }

    // A slightly darker (or, for very dark backgrounds, slightly lighter) shade of the pass's own
    // background color, so the plain and scalloped borders read as an edge of the same material
    // instead of an unrelated gray/black outline.
    private var borderColor: Color {
        Color(hex: backgroundColor).adjustingBrightness(by: backgroundBrightness == .veryDark ? 0.15 : -0.12)
    }

    // Darkens (or, for very dark backgrounds, lightens) the border layer's copy of the background
    // photo, so the notched border reads as an edge of the same photo instead of a flat, unrelated
    // color.
    private var imageBorderTint: Color {
        backgroundBrightness == .veryDark ? Color.white.opacity(0.18) : Color.black.opacity(0.18)
    }

    private var shadowColor: Color {
        switch backgroundBrightness {
        case .veryDark:
            return colorScheme == .light ? Color(hex: backgroundColor) : Color.gray.opacity(0.6)
        case .normal:
            return Color(hex: backgroundColor)
        case .veryLight:
            return colorScheme == .light ? Color.gray : Color(hex: backgroundColor).opacity(0.6)
        }
    }

    private var shadowOpacity: Double {
        switch backgroundBrightness {
        case .veryDark:
            return colorScheme == .light ? 0.5 : 0.4
        case .normal:
            return colorScheme == .light ? 0.5 : 0.6
        case .veryLight:
            return 0.4
        }
    }
}

#Preview {
    EditablePassCardBackground(backgroundImage: MockModelData().passObjects[0].backgroundImage, backgroundColor: MockModelData().passObjects[0].backgroundColor, backgroundBrightness: .normal, isCoupon: MockModelData().passObjects[0].isCoupon)
}
