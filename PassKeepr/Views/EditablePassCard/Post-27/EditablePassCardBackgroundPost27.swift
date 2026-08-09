import SwiftUI

struct NotchedRectanglePost27: InsettableShape {
    var notchRadius: CGFloat = 55
    var insetAmount: CGFloat = 0
    var verticalOffset: CGFloat = 43
    var cornerRadius: CGFloat = 10
    var notchCornerRadius: CGFloat = 10

    func path(in rect: CGRect) -> Path {
        var path = Path()

        // Apply inset to the rectangle
        let insetRect = rect.insetBy(dx: insetAmount, dy: insetAmount)

        // Calculate notch center position
        let notchCenterX = insetRect.minX + (insetRect.width / 2)
        let notchCenterY = insetRect.minY - verticalOffset // pull the center of the circle UP

        // Calculate inset notch radius
        let insetNotchRadius = notchRadius + insetAmount

        // Radius of the small fillets where the notch meets the flat top edge
        let notchFilletRadius = max(0, notchCornerRadius)

        // Each fillet's center sits `notchFilletRadius` below the top edge (so it's tangent to
        // the edge) and `insetNotchRadius + notchFilletRadius` away from the notch's own center
        // (so it's externally tangent to the notch's circle). Solving those two constraints with
        // the Pythagorean theorem gives its horizontal offset from the notch center.
        // See `docs/NotchedRectangleMath.pdf` for a visual explanation of the base (unfilleted) math.
        let filletCenterDistance = insetNotchRadius + notchFilletRadius
        let filletVerticalOffset = verticalOffset + notchFilletRadius
        let filletHalfSpan = sqrt(pow(filletCenterDistance, 2) - pow(filletVerticalOffset, 2))

        let leftFilletCenter = CGPoint(x: notchCenterX - filletHalfSpan, y: insetRect.minY + notchFilletRadius)
        let rightFilletCenter = CGPoint(x: notchCenterX + filletHalfSpan, y: insetRect.minY + notchFilletRadius)

        // Angle (relative to the notch circle's own center) where the main notch arc now
        // begins/ends, having ceded a bit of its sweep to the fillets on either side
        let notchStartAngle = Angle(radians: atan2(leftFilletCenter.y - notchCenterY, leftFilletCenter.x - notchCenterX))
        let notchEndAngle = Angle(radians: atan2(rightFilletCenter.y - notchCenterY, rightFilletCenter.x - notchCenterX))

        // Angle (relative to each fillet's own center) where it meets the notch circle
        let leftFilletToNotchAngle = Angle(radians: atan2(notchCenterY - leftFilletCenter.y, notchCenterX - leftFilletCenter.x))
        let rightFilletToNotchAngle = Angle(radians: atan2(notchCenterY - rightFilletCenter.y, notchCenterX - rightFilletCenter.x))

        // Clamp the corner radius so it never exceeds half of the rect's smallest dimension
        let r = max(0, min(cornerRadius, min(insetRect.width, insetRect.height) / 2))

        // Start on the top edge, just after the (rounded) top-left corner
        path.move(to: CGPoint(x: insetRect.minX + r, y: insetRect.minY))

        // Draw to where the left notch fillet begins
        path.addLine(to: CGPoint(x: leftFilletCenter.x, y: insetRect.minY))

        // Rounded corner where the notch meets the top edge (left side)
        path.addArc(
            center: leftFilletCenter,
            radius: notchFilletRadius,
            startAngle: .degrees(-90),
            endAngle: leftFilletToNotchAngle,
            clockwise: false
        )

        // Draw the partial circular notch (downward into rectangle)
        path.addArc(
            center: CGPoint(x: notchCenterX, y: notchCenterY),
            radius: insetNotchRadius,
            startAngle: notchStartAngle,
            endAngle: notchEndAngle,
            clockwise: true
        )

        // Rounded corner where the notch meets the top edge (right side)
        path.addArc(
            center: rightFilletCenter,
            radius: notchFilletRadius,
            startAngle: rightFilletToNotchAngle,
            endAngle: .degrees(-90),
            clockwise: false
        )

        // Continue to just before the top-right corner
        path.addLine(to: CGPoint(x: insetRect.maxX - r, y: insetRect.minY))

        // Rounded top-right corner
        path.addArc(
            center: CGPoint(x: insetRect.maxX - r, y: insetRect.minY + r),
            radius: r,
            startAngle: .degrees(-90),
            endAngle: .degrees(0),
            clockwise: false
        )

        // Right edge
        path.addLine(to: CGPoint(x: insetRect.maxX, y: insetRect.maxY - r))

        // Rounded bottom-right corner
        path.addArc(
            center: CGPoint(x: insetRect.maxX - r, y: insetRect.maxY - r),
            radius: r,
            startAngle: .degrees(0),
            endAngle: .degrees(90),
            clockwise: false
        )

        // Bottom edge
        path.addLine(to: CGPoint(x: insetRect.minX + r, y: insetRect.maxY))

        // Rounded bottom-left corner
        path.addArc(
            center: CGPoint(x: insetRect.minX + r, y: insetRect.maxY - r),
            radius: r,
            startAngle: .degrees(90),
            endAngle: .degrees(180),
            clockwise: false
        )

        // Left edge
        path.addLine(to: CGPoint(x: insetRect.minX, y: insetRect.minY + r))

        // Rounded top-left corner
        path.addArc(
            center: CGPoint(x: insetRect.minX + r, y: insetRect.minY + r),
            radius: r,
            startAngle: .degrees(180),
            endAngle: .degrees(270),
            clockwise: false
        )

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

struct EditablePassCardBackgroundPost27: View {
    @Environment(\.colorScheme) var colorScheme

    var backgroundImage: Data
    var backgroundColor: UInt
    var backgroundBrightness: BackgroundBrightness

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
    EditablePassCardBackgroundPost27(backgroundImage: MockModelData().passObjects[0].backgroundImage, backgroundColor: MockModelData().passObjects[0].backgroundColor, backgroundBrightness: .normal)
}
