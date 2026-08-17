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
        // The center X is the horizontal midpoint — inset is symmetric so both rect and insetRect give the same value.
        // The center Y is anchored to the *original* rect top (not insetRect.minY) so the notch center doesn't
        // drift as insetAmount increases. Keeping it fixed is required for a true parallel offset of the arc.
        let notchCenterX = insetRect.minX + (insetRect.width / 2)
        let notchCenterY = rect.minY - verticalOffset // pull the center of the circle UP

        // For this concave notch the inward normal at any arc point points *away* from the notch center
        // (toward the card body below), so a parallel inward offset of `d` maps every arc point to the
        // same circle but with radius `R + d`. The center must not shift with the inset — the original
        // code moved it down by insetAmount AND enlarged the radius, doubling the offset at the bottom
        // of the notch and producing a stroke that looked thicker there.
        let insetNotchRadius = notchRadius + insetAmount

        // Radius of the small fillets where the notch meets the flat top edge
        let notchFilletRadius = max(0, notchCornerRadius)

        // Each fillet's center sits `notchFilletRadius` below the inset top edge (tangent to it)
        // and `insetNotchRadius + notchFilletRadius` away from the notch's own center
        // (externally tangent to the notch circle). Solving those two constraints with
        // the Pythagorean theorem gives the horizontal offset from the notch center.
        // See `docs/NotchedRectangleMath.pdf` for a visual explanation of the base (unfilleted) math.
        //
        // Because the notch center is anchored to the original rect top while the fillet center is
        // anchored to the inset top edge, the vertical separation between them grows with insetAmount:
        //   notch center y  = rect.minY   - verticalOffset
        //   fillet center y = insetRect.minY + notchFilletRadius = rect.minY + insetAmount + notchFilletRadius
        //   vertical gap    = verticalOffset + insetAmount + notchFilletRadius
        let filletCenterDistance = insetNotchRadius + notchFilletRadius
        let filletVerticalOffset = verticalOffset + insetAmount + notchFilletRadius
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
        let r = max(0, min(cornerRadius - insetAmount, min(insetRect.width, insetRect.height) / 2))

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
