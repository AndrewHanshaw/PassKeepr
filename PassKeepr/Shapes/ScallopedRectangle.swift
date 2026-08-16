import SwiftUI

struct ScallopedRectangle: InsettableShape {
    var scallopsPerEdge: Int = 74
    var scallopSpacing: CGFloat = 1
    var insetAmount: CGFloat = 0

    func path(in rect: CGRect) -> Path {
        var path = Path()

        guard scallopsPerEdge > 0, rect.width > 0 else {
            path.addRect(rect.insetBy(dx: insetAmount, dy: insetAmount))
            return path
        }

        // The scallop wave (every arc's X position and radius) is always computed from the
        // shape's full, un-inset width so it's identical no matter what `insetAmount` is.
        // Without this, `strokeBorder` (which draws this same shape again at a small positive
        // `insetAmount`) would re-divide a slightly narrower width across the same scallop
        // count, rescaling every scallop and making the inset copy drift out of alignment with
        // the un-inset outline - worse the further a scallop is from the horizontal center.
        let totalSpacing = CGFloat(scallopsPerEdge - 1) * scallopSpacing
        let scallopWidth = (rect.width - totalSpacing) / CGFloat(scallopsPerEdge)
        let scallopRadius = scallopWidth / 2
        let segmentStride = scallopWidth + scallopSpacing

        // `insetAmount` only nudges the top/bottom edges vertically and the left/right edges
        // horizontally. Short bridging segments connect those inset corners to the (un-inset)
        // scallop grid so the wave itself never has to move.
        let left = rect.minX + insetAmount
        let right = rect.maxX - insetAmount
        let top = rect.minY + insetAmount
        let bottom = rect.maxY - insetAmount

        // Start at top-left corner
        path.move(to: CGPoint(x: left, y: top))
        path.addLine(to: CGPoint(x: rect.minX, y: top))

        // Top edge: scallops that curve down into the body of the rectangle, left to right,
        // separated by a short horizontal line
        for index in 0 ..< scallopsPerEdge {
            let segmentStartX = rect.minX + CGFloat(index) * segmentStride
            let centerX = segmentStartX + scallopRadius

            path.addArc(
                center: CGPoint(x: centerX, y: top),
                radius: scallopRadius,
                startAngle: .degrees(180),
                endAngle: .degrees(0),
                clockwise: true
            )

            if index < scallopsPerEdge - 1 {
                path.addLine(to: CGPoint(x: centerX + scallopRadius + scallopSpacing, y: top))
            }
        }

        // Bridge back out to the (possibly inset) right edge, then draw it
        path.addLine(to: CGPoint(x: right, y: top))
        path.addLine(to: CGPoint(x: right, y: bottom))

        // Bottom edge: scallops that curve up into the body of the rectangle, right to left,
        // separated by a short horizontal line
        path.addLine(to: CGPoint(x: rect.maxX, y: bottom))
        for index in stride(from: scallopsPerEdge - 1, through: 0, by: -1) {
            let segmentStartX = rect.minX + CGFloat(index) * segmentStride
            let centerX = segmentStartX + scallopRadius

            path.addArc(
                center: CGPoint(x: centerX, y: bottom),
                radius: scallopRadius,
                startAngle: .degrees(0),
                endAngle: .degrees(180),
                clockwise: true
            )

            if index > 0 {
                path.addLine(to: CGPoint(x: centerX - scallopRadius - scallopSpacing, y: bottom))
            }
        }

        // Bridge back to the (possibly inset) left edge, then close
        path.addLine(to: CGPoint(x: left, y: bottom))
        path.addLine(to: CGPoint(x: left, y: top))
        path.closeSubpath()

        return path
    }

    func inset(by amount: CGFloat) -> some InsettableShape {
        var shape = self
        shape.insetAmount += amount
        return shape
    }
}
