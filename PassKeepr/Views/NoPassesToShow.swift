import SwiftUI

struct NoPassesToShow: View {
    var addButtonCenter: CGPoint?

    var body: some View {
        if let addButtonCenter = addButtonCenter {
            GeometryReader { geometry in
                let readerGlobalFrame = geometry.frame(in: .global)
                let localButtonX = addButtonCenter.x - readerGlobalFrame.minX
                let localButtonY = addButtonCenter.y - readerGlobalFrame.minY

                let screenCenterX = geometry.size.width / 2
                let buttonIsOnRight = localButtonX > screenCenterX

                // for some reason the text alignment wouldn't work with a ternary so just create 2 separate views
                if buttonIsOnRight {
                    GuideViewButtonOnRight(
                        localButtonX: localButtonX,
                        localButtonY: localButtonY
                    )
                } else {
                    GuideViewButtonOnLeft(
                        localButtonX: localButtonX,
                        localButtonY: localButtonY
                    )
                }
            }
        } else {
            Color.clear
        }
    }
}

struct GuideViewButtonOnRight: View {
    let localButtonX: CGFloat
    let localButtonY: CGFloat

    var body: some View {
        ZStack {
            // Debug: Draw a circle at the button's center
            // Circle()
            //     .fill(Color.red)
            //     .frame(width: 12, height: 12)
            //     .position(x: localButtonX, y: localButtonY)

            Image(systemName: "arrow.turn.down.right")
                .font(.system(size: 36))
                .opacity(0.8)
                .position(x: localButtonX - 60, y: localButtonY - 0)

            Text("Use the ＋ Button\nto Add a Pass")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .multilineTextAlignment(.trailing)
                .frame(maxWidth: 180, alignment: .trailing)
                .opacity(0.8)
                .position(x: localButtonX - 140, y: localButtonY - 50)
        }
    }
}

struct GuideViewButtonOnLeft: View {
    let localButtonX: CGFloat
    let localButtonY: CGFloat

    var body: some View {
        ZStack {
            // Debug: Draw a circle at the button's center
            // Circle()
            //     .fill(Color.red)
            //     .frame(width: 12, height: 12)
            //     .position(x: localButtonX, y: localButtonY)

            Image(systemName: "arrow.turn.down.left")
                .font(.system(size: 36))
                .opacity(0.8)
                .position(x: localButtonX + 60, y: localButtonY - 0)

            Text("Use the ＋ Button\nto Add a Pass")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .multilineTextAlignment(.leading)
                .frame(maxWidth: 180, alignment: .leading)
                .opacity(0.8)
                .position(x: localButtonX + 140, y: localButtonY - 50)
        }
    }
}

#Preview {
    NoPassesToShow()
}
