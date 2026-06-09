import SwiftUI
import UIKit

// Auto-generates a pass colour scheme from its logo image when a logo is selected:
//   - the most common logo colour (excluding the edge colour) -> pass backgroundColor
//   - legible black/white                                     -> foregroundColor and labelColor
//   - the logo's outer-edge colour                            -> logoBackgroundColor
//
// Only runs when the colours are still at their defaults so manual edits are never clobbered.

private let defaultBackgroundColor: UInt = 0xFFFFFF
private let defaultForegroundColor: UInt = 0x000000
private let defaultLabelColor: UInt = 0x000000

func applyColorsFromLogo(to passObject: inout PassObject) {
    // Respect any manual colour choices the user has already made
    guard passObject.backgroundColor == defaultBackgroundColor,
          passObject.foregroundColor == defaultForegroundColor,
          passObject.labelColor == defaultLabelColor
    else { return }

    guard passObject.logoImage != Data(),
          let logo = UIImage(data: passObject.logoImage)
    else { return }

    // The edge colour is usually the logo's frame/background (e.g. white). Exclude it when picking
    // the dominant colour so a mostly-green logo framed in white still gives green as the card
    // background, while white is kept as the logo's edge colour.
    let edge = logo.edgeColor()
    let excluded = (edge?.isOpaque == true) ? edge?.color : nil
    guard let background = logo.dominantColor(excluding: excluded) else { return }

    passObject.backgroundColor = background.toUInt()
    passObject.foregroundColor = Color.legibleTextColor(onBackground: passObject.backgroundColor)
    passObject.labelColor = Color.legibleTextColor(onBackground: passObject.backgroundColor)

    if let edge = edge, edge.isOpaque {
        passObject.logoBackgroundColor = edge.color.toUInt()
        passObject.isLogoBackgroundOn = true
    } else {
        passObject.isLogoBackgroundOn = false
    }
}

// The logo image as it should be displayed/exported: if the logo tab is on, the logo is styled with a
// rounded top-left corner and a right/bottom border; otherwise the raw logo is returned. Because this
// reads passObject.backgroundColor, the result updates automatically whenever the background colour
// changes — in the preview (the view re-renders) and on export (re-baked).
func renderedLogoImage(for passObject: PassObject) -> UIImage? {
    guard let logo = UIImage(data: passObject.logoImage) else { return nil }
    guard passObject.isLogoBackgroundOn else { return logo }
    return logoWithCornerTab(
        logo,
        edgeColor: UIColor(hex: passObject.logoBackgroundColor),
        backgroundColor: UIColor(hex: passObject.backgroundColor)
    )
}

// Linear blend between two colours (t = 0 returns a, t = 1 returns b).
private func blend(_ a: UIColor, _ b: UIColor, _ t: CGFloat) -> UIColor {
    var ar: CGFloat = 0, ag: CGFloat = 0, ab: CGFloat = 0, aa: CGFloat = 0
    var br: CGFloat = 0, bg: CGFloat = 0, bb: CGFloat = 0, ba: CGFloat = 0
    a.getRed(&ar, green: &ag, blue: &ab, alpha: &aa)
    b.getRed(&br, green: &bg, blue: &bb, alpha: &ba)
    return UIColor(red: ar + (br - ar) * t, green: ag + (bg - ag) * t, blue: ab + (bb - ab) * t, alpha: 1)
}

// Styles the logo into a single opaque image (still one logo from Apple Wallet's point of view):
//   - the logo is drawn with a top band of background colour, so in the exported pass it isn't tucked
//     tighter to the top than the left
//   - only the top-left corner is rounded (convex), with the background colour filling the curve
//   - the right and bottom edges get a simple border line, graded halfway between the edge colour and
//     the background colour
// All sizes are fractions of the logo's shorter side / dimensions (resolution independent), so the
// shape looks the same regardless of the source image's pixel size.
func logoWithCornerTab(_ logo: UIImage, edgeColor: UIColor, backgroundColor: UIColor,
                       cornerRadiusRatio: CGFloat = 0.18, borderRatio: CGFloat = 0.05, topInsetRatio: CGFloat = 0.10) -> UIImage
{
    let logoSize = logo.size
    guard logoSize.width > 0, logoSize.height > 0 else { return logo }

    let minSide = min(logoSize.width, logoSize.height)
    let radius = minSide * cornerRadiusRatio
    let border = max(1, minSide * borderRatio)
    let topInset = logoSize.height * topInsetRatio

    let canvas = CGSize(width: logoSize.width, height: logoSize.height + topInset)
    let logoRect = CGRect(x: 0, y: topInset, width: logoSize.width, height: logoSize.height)

    let format = UIGraphicsImageRendererFormat.default()
    format.opaque = true // no transparency in the exported logo
    format.scale = logo.scale

    let renderer = UIGraphicsImageRenderer(size: canvas, format: format)
    return renderer.image { ctx in
        let cg = ctx.cgContext

        // Background everywhere — shows through the top band and the rounded top-left corner
        backgroundColor.setFill()
        cg.fill(CGRect(origin: .zero, size: canvas))

        // Logo with only its top-left corner rounded (convex)
        cg.saveGState()
        UIBezierPath(roundedRect: logoRect, byRoundingCorners: [.topLeft], cornerRadii: CGSize(width: radius, height: radius)).addClip()
        logo.draw(in: logoRect)

        // Simple border line on the right and bottom edges, graded halfway between the edge colour
        // and the background colour
        blend(edgeColor, backgroundColor, 0.5).setFill()
        cg.fill(CGRect(x: logoRect.maxX - border, y: logoRect.minY, width: border, height: logoSize.height)) // right
        cg.fill(CGRect(x: 0, y: canvas.height - border, width: logoSize.width, height: border)) // bottom
        cg.restoreGState()
    }
}
