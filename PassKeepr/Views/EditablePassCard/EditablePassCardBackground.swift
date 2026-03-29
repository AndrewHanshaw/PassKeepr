import SwiftUI

struct NotchedRectangle: InsettableShape {
    var notchRadius: CGFloat = 35
    var insetAmount: CGFloat = 0
    var verticalOffset: CGFloat = 20

    func path(in rect: CGRect) -> Path {
        var path = Path()

        // Apply inset to the rectangle
        let insetRect = rect.insetBy(dx: insetAmount, dy: insetAmount)

        // Calculate notch center position
        let notchCenterX = insetRect.minX + (insetRect.width / 2)
        let notchCenterY = insetRect.minY - verticalOffset // pull the center of the circle UP

        // Calculate inset notch radius
        let insetNotchRadius = notchRadius + insetAmount

        // Calculate where the arc intersects the top edge using Pythagorean theorem
        // See `docs/NotchedRectangleMath.pdf` for a visual explanation
        let horizontalDistance = sqrt(pow(insetNotchRadius, 2) - pow(verticalOffset, 2))

        // Calculate where to start the notch arc horizontally
        let arcStartX = notchCenterX - horizontalDistance

        // This is the angle between the y axis and the point where the rectangle ends and the arc begins
        // See `docs/NotchedRectangleMath.pdf` for a visual explanation
        let angle = acos(horizontalDistance / insetNotchRadius) * 180 / .pi

        // Start from top-left corner
        path.move(to: CGPoint(x: insetRect.minX, y: insetRect.minY))

        // Draw to the start of the notch
        path.addLine(to: CGPoint(x: arcStartX, y: insetRect.minY))

        // Draw the partial circular notch (downward into rectangle)
        path.addArc(
            center: CGPoint(x: notchCenterX, y: notchCenterY),
            radius: insetNotchRadius,
            startAngle: .degrees(180 - angle),
            endAngle: .degrees(angle),
            clockwise: true
        )

        // Continue to top right corner
        path.addLine(to: CGPoint(x: insetRect.maxX, y: insetRect.minY))

        // Right edge
        path.addLine(to: CGPoint(x: insetRect.maxX, y: insetRect.maxY))

        // Bottom edge
        path.addLine(to: CGPoint(x: insetRect.minX, y: insetRect.maxY))

        // Close the path
        path.closeSubpath()

        return path
    }

    func inset(by amount: CGFloat) -> some InsettableShape {
        var shape = self
        shape.insetAmount += amount
        return shape
    }
}

struct EditablePassCardBackground: View {
    @Environment(\.colorScheme) var colorScheme

    var backgroundImage: Data
    var backgroundColor: UInt
    var backgroundBrightness: BackgroundBrightness

    var body: some View {
        ZStack {
            if backgroundImage != Data() {
                imageBackground
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
    EditablePassCardBackground(backgroundImage: MockModelData().passObjects[0].backgroundImage, backgroundColor: MockModelData().passObjects[0].backgroundColor, backgroundBrightness: .normal)
}
