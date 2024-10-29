import SwiftUI

struct IconShape: Shape {
    @State var appIconSize: CGFloat
    @State var filletRadius: CGFloat
    @State var cornerDotRadius: CGFloat
    @State var bigDotRadius: CGFloat

    func path(in _: CGRect) -> Path {
        var path = Path()

        // Top left corner
        path.move(to: CGPoint(x: 0, y: 0))

        path.addArc(center: CGPoint(x: filletRadius, y: (appIconSize / 2) - (bigDotRadius + filletRadius)), radius: filletRadius, startAngle: .degrees(180), endAngle: .degrees(90), clockwise: true)

        // Left middle
        path.addArc(center: CGPoint(x: filletRadius, y: appIconSize / 2), radius: bigDotRadius, startAngle: .degrees(270), endAngle: .degrees(90), clockwise: false)

        path.addArc(center: CGPoint(x: filletRadius, y: appIconSize - ((appIconSize / 2) - (bigDotRadius + filletRadius))), radius: filletRadius, startAngle: .degrees(270), endAngle: .degrees(180), clockwise: true)

        // Bottom left corner
        path.addLine(to: CGPoint(x: 0, y: appIconSize))

        // Bottom right corner
        path.addLine(to: CGPoint(x: appIconSize, y: appIconSize))

        path.addArc(center: CGPoint(x: appIconSize - filletRadius, y: appIconSize - ((appIconSize / 2) - (bigDotRadius + filletRadius))), radius: filletRadius, startAngle: .degrees(0), endAngle: .degrees(270), clockwise: true)

        // Right middle
        path.addArc(center: CGPoint(x: appIconSize - filletRadius, y: appIconSize / 2), radius: bigDotRadius, startAngle: .degrees(90), endAngle: .degrees(270), clockwise: false)

        path.addArc(center: CGPoint(x: appIconSize - filletRadius, y: (appIconSize / 2) - (bigDotRadius + filletRadius)), radius: filletRadius, startAngle: .degrees(90), endAngle: .degrees(0), clockwise: true)

        // Top right corner
        path.addLine(to: CGPoint(x: appIconSize, y: 0))

        path.closeSubpath()

        return path
    }
}

struct IconShape2: Shape {
    @State var appIconSize: CGFloat
    @State var filletRadius: CGFloat
    @State var cornerDotRadius: CGFloat
    @State var bigDotRadius: CGFloat

    func path(in _: CGRect) -> Path {
        let offset: CGFloat = 100 * appIconSize / 1024
        let offset2 = 26 * appIconSize / 1024

        var path = Path()

        path.addArc(center: CGPoint(x: cornerDotRadius + 2 * filletRadius + offset, y: 0 + offset), radius: filletRadius, startAngle: .degrees(270), endAngle: .degrees(180), clockwise: true)

        path.addArc(center: CGPoint(x: filletRadius + offset, y: filletRadius + offset), radius: cornerDotRadius, startAngle: .degrees(0), endAngle: .degrees(90), clockwise: false)

        path.addArc(center: CGPoint(x: filletRadius + offset, y: cornerDotRadius + 2 * filletRadius + offset), radius: filletRadius, startAngle: .degrees(270), endAngle: .degrees(180), clockwise: true)

        path.addArc(center: CGPoint(x: filletRadius + offset, y: (appIconSize / 2) - (bigDotRadius + filletRadius) - offset + offset2), radius: filletRadius, startAngle: .degrees(180), endAngle: .degrees(93), clockwise: true)

        // Left middle
        path.addArc(center: CGPoint(x: filletRadius, y: appIconSize / 2), radius: bigDotRadius + offset, startAngle: .degrees(300), endAngle: .degrees(60), clockwise: false)

        path.addArc(center: CGPoint(x: filletRadius + offset, y: appIconSize - ((appIconSize / 2) - (bigDotRadius + filletRadius)) + offset - offset2), radius: filletRadius, startAngle: .degrees(270), endAngle: .degrees(180), clockwise: true)

        path.addArc(center: CGPoint(x: filletRadius + offset, y: appIconSize - (cornerDotRadius + filletRadius) - offset), radius: filletRadius, startAngle: .degrees(180), endAngle: .degrees(90), clockwise: true)

        // Bottom left corner
        path.addArc(center: CGPoint(x: filletRadius + offset, y: appIconSize - offset), radius: cornerDotRadius, startAngle: .degrees(270), endAngle: .degrees(0), clockwise: false)

        path.addArc(center: CGPoint(x: cornerDotRadius + 2 * filletRadius + offset, y: appIconSize - offset), radius: filletRadius, startAngle: .degrees(180), endAngle: .degrees(90), clockwise: true)

        path.addArc(center: CGPoint(x: appIconSize - (cornerDotRadius + 2 * filletRadius) - offset, y: appIconSize - offset), radius: filletRadius, startAngle: .degrees(90), endAngle: .degrees(0), clockwise: true)

        // Bottom right corner
        path.addArc(center: CGPoint(x: appIconSize - filletRadius - offset, y: appIconSize - offset), radius: cornerDotRadius, startAngle: .degrees(180), endAngle: .degrees(270), clockwise: false)

        path.addArc(center: CGPoint(x: appIconSize - filletRadius - offset, y: appIconSize - (cornerDotRadius + filletRadius) - offset), radius: filletRadius, startAngle: .degrees(90), endAngle: .degrees(0), clockwise: true)

        path.addArc(center: CGPoint(x: appIconSize - filletRadius - offset, y: appIconSize - ((appIconSize / 2) - (bigDotRadius + filletRadius)) + offset - offset2), radius: filletRadius, startAngle: .degrees(0), endAngle: .degrees(270), clockwise: true)

        // Right middle
        path.addArc(center: CGPoint(x: appIconSize - filletRadius, y: appIconSize / 2), radius: bigDotRadius + offset, startAngle: .degrees(120), endAngle: .degrees(240), clockwise: false)

        path.addArc(center: CGPoint(x: appIconSize - filletRadius - offset, y: (appIconSize / 2) - (bigDotRadius + filletRadius) - offset + offset2), radius: filletRadius, startAngle: .degrees(90), endAngle: .degrees(0), clockwise: true)

        path.addArc(center: CGPoint(x: appIconSize - filletRadius - offset, y: cornerDotRadius + 2 * filletRadius + offset), radius: filletRadius, startAngle: .degrees(0), endAngle: .degrees(270), clockwise: true)

        // Top right corner
        path.addArc(center: CGPoint(x: appIconSize - filletRadius - offset, y: filletRadius + offset), radius: cornerDotRadius, startAngle: .degrees(90), endAngle: .degrees(180), clockwise: false)

        path.addArc(center: CGPoint(x: appIconSize - (cornerDotRadius + 2 * filletRadius) - offset, y: 0 + offset), radius: filletRadius, startAngle: .degrees(0), endAngle: .degrees(270), clockwise: true)

        path.closeSubpath()
        return path.strokedPath(.init(lineWidth: 15 * appIconSize / 1024))
    }
}

struct AppIcon: View {
    static let maincolor: Color = .init(hex: 0x173C1C)
    static let maincolortint2: Color = .init(hex: 0x456349)

    static let outlineColor: Color = .init(hex: 0x389144)
    static let outlineColortint2: Color = .init(hex: 0x60A769)
    static let outlineColortint4: Color = .init(hex: 0x88BD8F)

    var body: some View {
        GeometryReader { geometry in
            let appIconSize = geometry.size.width
            let bigDotRadius = 120 * (appIconSize / 1024)
            let cornerDotRadius = 50 * (appIconSize / 1024)
            let filletRadius = 10 * (appIconSize / 1024)

            ZStack {
                LinearGradient(colors: [AppIcon.outlineColortint4, AppIcon.outlineColortint2], startPoint: .top, endPoint: .bottom)
                IconShape(appIconSize: appIconSize, filletRadius: filletRadius, cornerDotRadius: cornerDotRadius, bigDotRadius: bigDotRadius)
                    .fill(LinearGradient(colors: [AppIcon.maincolortint2, AppIcon.maincolor], startPoint: .top, endPoint: .bottom))
                    .shadow(radius: 20)
                IconShape2(appIconSize: appIconSize, filletRadius: filletRadius, cornerDotRadius: cornerDotRadius, bigDotRadius: bigDotRadius)
                    .fill(LinearGradient(colors: [AppIcon.outlineColortint2, AppIcon.outlineColor], startPoint: .top, endPoint: .bottom))
                    .shadow(radius: 20)
                LinearGradient(colors: [AppIcon.outlineColortint4, AppIcon.outlineColor], startPoint: .top, endPoint: .bottom)
                    .mask(Text("P")
                        .font(Font.system(size: 500 * (appIconSize / 1024), weight: .bold))
                        .italic()
                        .offset(x: -50 * appIconSize / 1024, y: -150 * appIconSize / 1024)
                    )
                    .shadow(radius: 20)

                LinearGradient(colors: [AppIcon.outlineColortint4, AppIcon.outlineColor], startPoint: .top, endPoint: .bottom)
                    .mask(Text("K")
                        .font(Font.system(size: 500 * (appIconSize / 1024), weight: .bold))
                        .italic()
                        .offset(x: (50 * (appIconSize / 1024)), y: (150 * (appIconSize / 1024)))
                    )
                    .shadow(radius: 20)
            }.frame(width: geometry.size.width, height: geometry.size.width)
        }
    }
}

#Preview {
    AppIcon()
}
