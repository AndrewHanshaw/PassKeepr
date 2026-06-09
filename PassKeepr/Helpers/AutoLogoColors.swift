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
