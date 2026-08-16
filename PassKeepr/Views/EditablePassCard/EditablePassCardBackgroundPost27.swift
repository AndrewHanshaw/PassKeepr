import SwiftUI

struct EditablePassCardBackgroundPost27: View {
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
            if backgroundImage != Data() {
                imageBackground
            } else if isCoupon {
                scalloppedBackground
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
        .clipShape(gradientClipShape)
        .allowsHitTesting(false)
    }

    private var gradientClipShape: AnyShape {
        if backgroundImage != Data() {
            AnyShape(NotchedRectanglePost27())
        } else {
            AnyShape(RoundedRectangle(cornerRadius: 10))
        }
    }

    private var imageBackground: some View {
        ZStack {
            // Colored shadow for the background, similar to the native iOS effect
            NotchedRectanglePost27()
                .fill(Color.clear) // If you don't do this the fill is the opposite of the color scheme which, when combined with opacity, makes the shadow wrong
                .background(
                    Image(uiImage: UIImage(data: backgroundImage)!)
                        .resizable()
                        .clipShape(NotchedRectanglePost27())
                )
                .scaleEffect(0.95, anchor: .bottom)
                .blur(radius: 8)
                .opacity(colorScheme == .light ? 0.5 : 0.6)
                .padding(.bottom, -4)

            // "Real" background
            NotchedRectanglePost27()
                .strokeBorder(backgroundBrightness == .veryDark ? Color.gray.opacity(0.25) : Color.black.opacity(0.1), lineWidth: 2) // strokeBorder draws the line only on the inside of the view
                .background(
                    Image(uiImage: UIImage(data: backgroundImage)!)
                        .resizable()
                        .scaleEffect(1.05) // Scale up the image slightly to prevent a semitransparent halo around the image
                        .blur(radius: 6)
                        .clipShape(NotchedRectanglePost27())
                )
        }
    }

    private var plainColorBackground: some View {
        ZStack {
            // Colored shadow for the background, similar to the native iOS effect
            RoundedRectangle(cornerRadius: 10)
                .fill(shadowColor) // Want to use fill here because there is no strokeborder for the shadow and using .background causes issues with opacity (it uses inverted colors vs the ColorScheme)
                .scaleEffect(0.95, anchor: .bottom)
                .blur(radius: 12)
                .opacity(shadowOpacity)
                .padding(.bottom, -4)

            // "Real" background
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(backgroundBrightness == .veryDark ? Color.gray.opacity(0.25) : Color.black.opacity(0.1), lineWidth: 2) // strokeBorder draws the line only on the inside of the view
                .background { // Want to use background here because .fill overwrites the strokeborder. Ok because there is no opacity modifier
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(hex: backgroundColor))
                }
        }
    }

    private var scalloppedBackground: some View {
        ZStack {
            // Colored shadow for the background, similar to the native iOS effect
            // (use rounded rectangle for performance)

            // "Real" background
            ScallopedRectangle()
                .strokeBorder(backgroundBrightness == .veryDark ? Color.gray.opacity(0.25) : Color.black.opacity(0.1), lineWidth: 2) // strokeBorder draws the line only on the inside of the view
                .background { // Want to use background here because .fill overwrites the strokeborder. Ok because there is no opacity modifier
                    ScallopedRectangle()
                        .fill(Color(hex: backgroundColor))
                }
        }
        // Render this whole subtree into a single cached Metal-backed texture instead of having
        // Core Graphics re-rasterize the ~300-segment scalloped path in software on every color
        // change. This is what actually needs to happen for a color drag to feel instant - the
        // shape geometry never changes here, only its fill/stroke color does.
        .drawingGroup()
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
    EditablePassCardBackgroundPost27(backgroundImage: MockModelData().passObjects[0].backgroundImage, backgroundColor: MockModelData().passObjects[0].backgroundColor, backgroundBrightness: .normal, isCoupon: MockModelData().passObjects[0].isCoupon)
}
