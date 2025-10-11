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
    @Binding var passObject: PassObject

    var body: some View {
        if passObject.backgroundImage != Data() {
            NotchedRectangle()
                .strokeBorder(Color.black.opacity(0.1), lineWidth: 2) // strokeBorder draws the line only on the inside of the view
                .background(
                    Image(uiImage: UIImage(data: passObject.backgroundImage)!)
                        .resizable()
                        .scaleEffect(1.05) // Scale up the image slightly to prevent a semitransparent halo around the image
                        .blur(radius: 6)
                        .clipShape(NotchedRectangle())
                        .background(Color.clear) // not needed?
                )
        } else {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(hex: passObject.backgroundColor))
                .strokeBorder(Color.black.opacity(0.1), lineWidth: 2) // strokeBorder draws the line only on the inside of the view
                .background {
                    Color(hex: passObject.backgroundColor)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
        }
    }
}

#Preview {
    EditablePassCardBackground(passObject: .constant(MockModelData().passObjects[0]))
}
