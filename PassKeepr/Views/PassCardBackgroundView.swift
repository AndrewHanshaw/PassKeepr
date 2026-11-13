import PassKeeprCore
import SwiftUI

// Shared styling logic for the pass card background: border/shadow color math (`PassCardBackgroundColors`),
// the top/bottom vertical gradient overlay (`PassCardGradientOverlay`), and shape-selection
// branching (`PassCardShape`). `PassCardShape.background` is also referenced directly by
// `EditablePassCard`'s signing overlay to keep its clip shape in sync with the card's own shape.
struct PassCardBackgroundColors {
    var backgroundColor: UInt
    var backgroundBrightness: BackgroundBrightness
    var colorScheme: ColorScheme

    // A slightly darker (or, for very dark backgrounds, slightly lighter) shade of the pass's own
    // background color, so the plain and scalloped borders read as an edge of the same material
    // instead of an unrelated gray/black outline.
    var borderColor: Color {
        Color(hex: backgroundColor).adjustingBrightness(by: backgroundBrightness == .veryDark ? 0.15 : -0.12)
    }

    // Darkens (or, for very dark backgrounds, lightens) the border layer's copy of the background
    // photo, so the notched border reads as an edge of the same photo instead of a flat, unrelated
    // color.
    var imageBorderTint: Color {
        backgroundBrightness == .veryDark ? Color.white.opacity(0.18) : Color.black.opacity(0.18)
    }

    var shadowOpacity: Double {
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

// The subtle top/bottom vertical shading applied over every pass card background, clipped to
// whatever silhouette (notched, scalloped, or plain rounded) the card actually is.
struct PassCardGradientOverlay: View {
    var clipShape: AnyShape

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
        .clipShape(clipShape)
        .allowsHitTesting(false)
    }
}

enum PassCardShape {
    static func notch(insetAmount: CGFloat = 0) -> AnyShape {
        let shape = NotchedRectangle(insetAmount: insetAmount)
        return AnyShape(shape)
    }

    static func scallop(scallopsPerEdge: Int? = nil, insetAmount: CGFloat = 0) -> AnyShape {
        var shape = ScallopedRectangle(insetAmount: insetAmount)
        if let scallopsPerEdge { shape.scallopsPerEdge = scallopsPerEdge }
        return AnyShape(shape)
    }

    static func background(hasBackgroundImage: Bool, isCoupon: Bool, scallopsPerEdge: Int? = nil, insetAmount: CGFloat = 0) -> AnyShape {
        if hasBackgroundImage {
            notch(insetAmount: insetAmount)
        } else if isCoupon {
            scallop(scallopsPerEdge: scallopsPerEdge, insetAmount: insetAmount)
        } else {
            AnyShape(RoundedRectangle(cornerRadius: 10).inset(by: insetAmount))
        }
    }
}

// Shared background renderer for both the editable pass card (`EditablePassCard`) and the
// read-only display card (`PassCard`). The two only ever differed in shape sizing (the display
// card renders at ~52% of the editable card's width) - everything else (shadow, layered borders,
// gradient overlay, background-image caching) was byte-for-byte duplicated, so this is the single
// source of truth for all of it now.
struct PassCardBackgroundView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.displayScale) private var displayScale
    @State private var cachedBackgroundImage: UIImage?
    // For the grid only, fallback for the baked image below, set once background generation finishes.
    // The body reads `PassBackgroundImageCache` first so a cache hit never waits on state.
    @State private var bakedBlurredImage: UIImage?

    var passObject: PassObject
    var isEditable: Bool = false

    // Shape sizing - `nil` uses each shape's own default (used by the full-size editable card).
    // The smaller read-only `PassCard` overrides these to match its reduced rendered size.
    var scallopsPerEdge: Int?

    // Set only by the scrolling pass grid (`PassCard`), with the card's size in points.
    // In this mode the background photo is downscaled to the card's pixel size and its blur is baked into
    // a cached image once (see `PassBackgroundImageCache`) instead of decoding the full-resolution
    // photo and running live `.blur` passes per card.
    // `nil` keeps the original full-resolution, live-blur rendering (for edit and picker screens)
    var gridCardSize: CGSize?

    private var isGridMode: Bool { gridCardSize != nil }

    // The card's size in device pixels, or nil if there is nothing to bake
    // (not grid mode, no background photo, or the card size has not been measured yet).
    private var bakePixelSize: CGSize? {
        guard let size = gridCardSize, size.width > 0, size.height > 0, passObject.shouldIncludeBackgroundImage else { return nil }
        return CGSize(width: (size.width * displayScale).rounded(), height: (size.height * displayScale).rounded())
    }

    private struct BakeID: Hashable {
        var id: UUID
        var dataCount: Int
        var pixelSize: CGSize
    }

    private var bakeID: BakeID? {
        bakePixelSize.map { BakeID(id: passObject.id, dataCount: passObject.backgroundImage.count, pixelSize: $0) }
    }

    private func bakedImage(fallback: UIImage?) -> UIImage? {
        if let size = bakePixelSize,
           let hit = PassBackgroundImageCache.cachedImage(id: passObject.id, dataCount: passObject.backgroundImage.count, pixelSize: size)
        {
            return hit
        }
        return fallback
    }

    // Photo used by the shadow, border and background layers; in grid mode its blur is already baked in
    // (the shadow layer just blurs it a bit further).
    private var blurredPhotoImage: UIImage? {
        isGridMode ? bakedImage(fallback: bakedBlurredImage) : cachedBackgroundImage
    }

    private var colors: PassCardBackgroundColors {
        PassCardBackgroundColors(backgroundColor: passObject.backgroundColor, backgroundBrightness: passObject.backgroundBrightness, colorScheme: colorScheme)
    }

    // Shared by both the shadow (filled) and the gradient overlay (used as a clip shape) so the
    // two always agree on which silhouette - notched, scalloped, or plain rounded - to use.
    private var backgroundShape: AnyShape {
        PassCardShape.background(hasBackgroundImage: passObject.shouldIncludeBackgroundImage, isCoupon: passObject.isCoupon, scallopsPerEdge: scallopsPerEdge)
    }

    private func notchShape(insetAmount: CGFloat = 0) -> AnyShape {
        PassCardShape.notch(insetAmount: insetAmount)
    }

    private func scallopShape(insetAmount: CGFloat = 0) -> AnyShape {
        PassCardShape.scallop(scallopsPerEdge: scallopsPerEdge, insetAmount: insetAmount)
    }

    private var shadow: some View {
        if passObject.shouldIncludeBackgroundImage {
            return AnyView(
                Image(uiImage: blurredPhotoImage ?? UIImage())
                    .resizable()
                    .scaleEffect(1.05)
                    .clipShape(notchShape(insetAmount: 2))
            )
        } else if passObject.isCoupon {
            return AnyView(
                scallopShape(insetAmount: 2)
                    .fill(Color(hex: passObject.backgroundColor))
            )
        } else {
            return AnyView(
                RoundedRectangle(cornerRadius: 10)
                    .inset(by: 2)
                    .fill(Color(hex: passObject.backgroundColor))
            )
        }
    }

    var body: some View {
        ZStack {
            backgroundShape
                .fill(Color.clear)
                .background(shadow)
                .scaleEffect(0.95, anchor: .bottom)
                .blur(radius: 8)
                .opacity(colors.shadowOpacity)
                .padding(.bottom, -4)

            if passObject.shouldIncludeBackgroundImage {
                imageBackground
            } else if passObject.isCoupon {
                scallopedBackground
            } else {
                plainColorBackground
            }

            if #available(iOS 27.0, *) {
                PassCardGradientOverlay(clipShape: backgroundShape)
            }
        }
        .onChange(of: passObject.backgroundImage) { _, newValue in
            if !isGridMode, passObject.isBackgroundImageOn {
                decodeBackgroundImage(newValue)
            }
        }
        .onChange(of: passObject.isBackgroundImageOn) { _, isOn in
            if !isGridMode, isOn && passObject.backgroundImage != Data() {
                decodeBackgroundImage(passObject.backgroundImage)
            }
        }
        .onAppear {
            if !isGridMode, passObject.isBackgroundImageOn {
                decodeBackgroundImage(passObject.backgroundImage)
            }
        }
        // Generate the downscaled/pre-blurred images off the main thread
        // Re-runs when the photo or the card's pixel size changes
        .task(id: bakeID) {
            await bakeGridImages()
        }
    }

    private func bakeGridImages() async {
        guard let pixelSize = bakePixelSize else {
            bakedBlurredImage = nil
            return
        }
        let id = passObject.id
        let data = passObject.backgroundImage
        let scale = displayScale
        if PassBackgroundImageCache.cachedImage(id: id, dataCount: data.count, pixelSize: pixelSize) != nil {
            return
        }
        let result = await Task.detached(priority: .userInitiated) {
            PassBackgroundImageCache.generate(id: id, data: data, pixelSize: pixelSize, displayScale: scale)
        }.value
        guard !Task.isCancelled else { return }
        bakedBlurredImage = result
    }

    // The photo for the border and background layers
    // In grid mode the blur is already baked into the image, it is applied live everywhere else
    // Only call when `blurredPhotoImage` is non-nil.
    @ViewBuilder
    private func blurredPhoto(_ image: UIImage) -> some View {
        if isGridMode {
            Image(uiImage: image)
                .resizable()
                .scaleEffect(1.05)
        } else {
            Image(uiImage: image)
                .resizable()
                .scaleEffect(1.05) // Scale up the image slightly to prevent a semitransparent halo around the image
                .blur(radius: 6)
        }
    }

    private var imageBackground: some View {
        let photo = blurredPhotoImage
        return ZStack {
            // Border - the same photo, tinted darker/lighter, so the border reads as an edge of the
            // actual image instead of a flat, unrelated color.
            notchShape()
                .fill(Color.clear)
                .background(
                    photo != nil ?
                        AnyView(
                            blurredPhoto(photo!)
                                .overlay(colors.imageBorderTint)
                                .clipShape(notchShape())
                        )
                        : AnyView(Color.clear)
                )

            // "Real" background
            notchShape(insetAmount: 2)
                .fill(Color.clear)
                .background(
                    photo != nil ?
                        AnyView(
                            blurredPhoto(photo!)
                                .clipShape(notchShape(insetAmount: 2))
                        )
                        : AnyView(Color.clear)
                )
        }
    }

    private var plainColorBackground: some View {
        ZStack {
            // Border
            RoundedRectangle(cornerRadius: 10)
                .fill(colors.borderColor)

            // "Real" background
            RoundedRectangle(cornerRadius: 10)
                .inset(by: 2)
                .fill(Color(hex: passObject.backgroundColor))
        }
    }

    private var scallopedBackground: some View {
        let background = ZStack {
            // Border
            scallopShape()
                .fill(colors.borderColor)

            // "Real" background
            scallopShape(insetAmount: 2)
                .fill(Color(hex: passObject.backgroundColor))
        }

        // Cache the scalloped shape for performance when editing. Skip the cache during normal display (keeps the drag preview rendering correct).
        if isEditable {
            // Render this whole subtree into a single cached texture instead of re-rasterizing the ~300-segment scalloped path
            // on every color change. The shape geometry never changes, only the fill/stroke color
            return AnyView(background.drawingGroup())
        } else {
            return AnyView(background)
        }
    }

    // Decodes the background image (if any) for rendering, caching it in @State so repeated body
    // re-evaluations (e.g. from unrelated edits while customizing a pass) don't re-decode it.
    private func decodeBackgroundImage(_ data: Data) {
        cachedBackgroundImage = data == Data() ? nil : UIImage(data: data)
    }
}

#Preview {
    PassCardBackgroundView(passObject: MockModelData().passObjects[0])
}
