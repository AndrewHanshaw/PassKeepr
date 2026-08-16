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
