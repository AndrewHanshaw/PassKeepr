import SwiftUI

struct EditablePassCardBackground: View {
    @Environment(\.colorScheme) var colorScheme

    var backgroundImage: Data
    var backgroundColor: UInt
    var backgroundBrightness: BackgroundBrightness
    var isCoupon: Bool

    var body: some View {
        ZStack {
            if backgroundImage != Data() {
                imageBackground
            } else if isCoupon {
                scalloppedBackground
            } else {
                plainColorBackground
            }
        }
    }

    private var imageBackground: some View {
        ZStack {
            // Colored shadow for the background, similar to the native iOS effect
            NotchedRectangle()
                .fill(Color.clear) // If you don't do this the fill is the opposite of the color scheme which, when combined with opacity, makes the shadow wrong
                .background(
                    Image(uiImage: UIImage(data: backgroundImage)!)
                        .resizable()
                        .clipShape(NotchedRectangle())
                )
                .scaleEffect(0.95, anchor: .bottom)
                .blur(radius: 8)
                .opacity(colorScheme == .light ? 0.5 : 0.6)
                .padding(.bottom, -4)

            // "Real" background
            NotchedRectangle()
                .strokeBorder(backgroundBrightness == .veryDark ? Color.gray.opacity(0.25) : Color.black.opacity(0.1), lineWidth: 2) // strokeBorder draws the line only on the inside of the view
                .background(
                    Image(uiImage: UIImage(data: backgroundImage)!)
                        .resizable()
                        .scaleEffect(1.05) // Scale up the image slightly to prevent a semitransparent halo around the image
                        .blur(radius: 6)
                        .clipShape(NotchedRectangle())
                )
        }
    }

    private var plainColorBackground: some View {
        ZStack {
            // Colored shadow for the background, similar to the native iOS effect
            RoundedRectangle(cornerRadius: 10)
                .fill(shadowColor) // Want to use fill here because there is no strokeborder for the shadow and using .background causes issues with opacity (it uses inverted colors vs the ColorScheme)
                .scaleEffect(0.95, anchor: .bottom)
                .blur(radius: 8)
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
            // Rounded rectangle for the shadow because scallops are too small to be visible in the shadow anyway so it's wasted compute
            RoundedRectangle(cornerRadius: 10)
                .fill(shadowColor) // Want to use fill here because there is no strokeborder for the shadow and using .background causes issues with opacity (it uses inverted colors vs the ColorScheme)
                .scaleEffect(0.95, anchor: .bottom)
                .blur(radius: 8)
                .opacity(shadowOpacity)
                .padding(.bottom, -4)

            // "Real" background
            ScallopedRectangle()
                .strokeBorder(backgroundBrightness == .veryDark ? Color.gray.opacity(0.25) : Color.black.opacity(0.1), lineWidth: 2) // strokeBorder draws the line only on the inside of the view
                .background { // Want to use background here because .fill overwrites the strokeborder. Ok because there is no opacity modifier
                    ScallopedRectangle()
                        .fill(Color(hex: backgroundColor))
                }
        }
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
