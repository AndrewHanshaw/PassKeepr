//
//  AppIcon.swift
//  PassKeepr
//
//  Created by Andrew Hanshaw on 12/27/23.
//

import SwiftUI

struct IconShape: Shape {
    func path(in _: CGRect) -> Path {
        var path = Path()

        // Top left corner
        path.move(to: CGPoint(x: 0, y: 0))

        path.addArc(center: CGPoint(x: AppIcon.filletRadius, y: (AppIcon.appIconSize / 2) - (AppIcon.bigDotRadius + AppIcon.filletRadius)), radius: AppIcon.filletRadius, startAngle: .degrees(180), endAngle: .degrees(90), clockwise: true)

        // Left middle
        path.addArc(center: CGPoint(x: AppIcon.filletRadius, y: AppIcon.appIconSize / 2), radius: AppIcon.bigDotRadius, startAngle: .degrees(270), endAngle: .degrees(90), clockwise: false)

        path.addArc(center: CGPoint(x: AppIcon.filletRadius, y: AppIcon.appIconSize - ((AppIcon.appIconSize / 2) - (AppIcon.bigDotRadius + AppIcon.filletRadius))), radius: AppIcon.filletRadius, startAngle: .degrees(270), endAngle: .degrees(180), clockwise: true)

        // Bottom left corner
        path.addLine(to: CGPoint(x: 0, y: AppIcon.appIconSize))

        // Bottom right corner
        path.addLine(to: CGPoint(x: AppIcon.appIconSize, y: AppIcon.appIconSize))

        path.addArc(center: CGPoint(x: AppIcon.appIconSize - AppIcon.filletRadius, y: AppIcon.appIconSize - ((AppIcon.appIconSize / 2) - (AppIcon.bigDotRadius + AppIcon.filletRadius))), radius: AppIcon.filletRadius, startAngle: .degrees(0), endAngle: .degrees(270), clockwise: true)

        // Right middle
        path.addArc(center: CGPoint(x: AppIcon.appIconSize - AppIcon.filletRadius, y: AppIcon.appIconSize / 2), radius: AppIcon.bigDotRadius, startAngle: .degrees(90), endAngle: .degrees(270), clockwise: false)

        path.addArc(center: CGPoint(x: AppIcon.appIconSize - AppIcon.filletRadius, y: (AppIcon.appIconSize / 2) - (AppIcon.bigDotRadius + AppIcon.filletRadius)), radius: AppIcon.filletRadius, startAngle: .degrees(90), endAngle: .degrees(0), clockwise: true)

        // Top right corner
        path.addLine(to: CGPoint(x: AppIcon.appIconSize, y: 0))

        path.closeSubpath()

        return path
    }
}

struct IconShape2: Shape {
    func path(in _: CGRect) -> Path {
        let offset: CGFloat = 100

        var path = Path()

        path.addArc(center: CGPoint(x: AppIcon.cornerDotRadius + 2 * AppIcon.filletRadius + offset, y: 0 + offset), radius: AppIcon.filletRadius, startAngle: .degrees(270), endAngle: .degrees(180), clockwise: true)

        path.addArc(center: CGPoint(x: AppIcon.filletRadius + offset, y: AppIcon.filletRadius + offset), radius: AppIcon.cornerDotRadius, startAngle: .degrees(0), endAngle: .degrees(90), clockwise: false)

        path.addArc(center: CGPoint(x: AppIcon.filletRadius + offset, y: AppIcon.cornerDotRadius + 2 * AppIcon.filletRadius + offset), radius: AppIcon.filletRadius, startAngle: .degrees(270), endAngle: .degrees(180), clockwise: true)

        path.addArc(center: CGPoint(x: AppIcon.filletRadius + offset, y: (AppIcon.appIconSize / 2) - (AppIcon.bigDotRadius + AppIcon.filletRadius) - offset + 26), radius: AppIcon.filletRadius, startAngle: .degrees(180), endAngle: .degrees(93), clockwise: true)

        // Left middle
        path.addArc(center: CGPoint(x: AppIcon.filletRadius, y: AppIcon.appIconSize / 2), radius: AppIcon.bigDotRadius + offset, startAngle: .degrees(300), endAngle: .degrees(60), clockwise: false)

        path.addArc(center: CGPoint(x: AppIcon.filletRadius + offset, y: AppIcon.appIconSize - ((AppIcon.appIconSize / 2) - (AppIcon.bigDotRadius + AppIcon.filletRadius)) + offset - 26), radius: AppIcon.filletRadius, startAngle: .degrees(270), endAngle: .degrees(180), clockwise: true)

        path.addArc(center: CGPoint(x: AppIcon.filletRadius + offset, y: AppIcon.appIconSize - (AppIcon.cornerDotRadius + AppIcon.filletRadius) - offset), radius: AppIcon.filletRadius, startAngle: .degrees(180), endAngle: .degrees(90), clockwise: true)

        // Bottom left corner
        path.addArc(center: CGPoint(x: AppIcon.filletRadius + offset, y: AppIcon.appIconSize - offset), radius: AppIcon.cornerDotRadius, startAngle: .degrees(270), endAngle: .degrees(0), clockwise: false)

        path.addArc(center: CGPoint(x: AppIcon.cornerDotRadius + 2 * AppIcon.filletRadius + offset, y: AppIcon.appIconSize - offset), radius: AppIcon.filletRadius, startAngle: .degrees(180), endAngle: .degrees(90), clockwise: true)

        path.addArc(center: CGPoint(x: AppIcon.appIconSize - (AppIcon.cornerDotRadius + 2 * AppIcon.filletRadius) - offset, y: AppIcon.appIconSize - offset), radius: AppIcon.filletRadius, startAngle: .degrees(90), endAngle: .degrees(0), clockwise: true)

        // Bottom right corner
        path.addArc(center: CGPoint(x: AppIcon.appIconSize - AppIcon.filletRadius - offset, y: AppIcon.appIconSize - offset), radius: AppIcon.cornerDotRadius, startAngle: .degrees(180), endAngle: .degrees(270), clockwise: false)

        path.addArc(center: CGPoint(x: AppIcon.appIconSize - AppIcon.filletRadius - offset, y: AppIcon.appIconSize - (AppIcon.cornerDotRadius + AppIcon.filletRadius) - offset), radius: AppIcon.filletRadius, startAngle: .degrees(90), endAngle: .degrees(0), clockwise: true)

        path.addArc(center: CGPoint(x: AppIcon.appIconSize - AppIcon.filletRadius - offset, y: AppIcon.appIconSize - ((AppIcon.appIconSize / 2) - (AppIcon.bigDotRadius + AppIcon.filletRadius)) + offset - 26), radius: AppIcon.filletRadius, startAngle: .degrees(0), endAngle: .degrees(270), clockwise: true)

        // Right middle
        path.addArc(center: CGPoint(x: AppIcon.appIconSize - AppIcon.filletRadius, y: AppIcon.appIconSize / 2), radius: AppIcon.bigDotRadius + offset, startAngle: .degrees(120), endAngle: .degrees(240), clockwise: false)

        path.addArc(center: CGPoint(x: AppIcon.appIconSize - AppIcon.filletRadius - offset, y: (AppIcon.appIconSize / 2) - (AppIcon.bigDotRadius + AppIcon.filletRadius) - offset + 26), radius: AppIcon.filletRadius, startAngle: .degrees(90), endAngle: .degrees(0), clockwise: true)

        path.addArc(center: CGPoint(x: AppIcon.appIconSize - AppIcon.filletRadius - offset, y: AppIcon.cornerDotRadius + 2 * AppIcon.filletRadius + offset), radius: AppIcon.filletRadius, startAngle: .degrees(0), endAngle: .degrees(270), clockwise: true)

        // Top right corner
        path.addArc(center: CGPoint(x: AppIcon.appIconSize - AppIcon.filletRadius - offset, y: AppIcon.filletRadius + offset), radius: AppIcon.cornerDotRadius, startAngle: .degrees(90), endAngle: .degrees(180), clockwise: false)

        path.addArc(center: CGPoint(x: AppIcon.appIconSize - (AppIcon.cornerDotRadius + 2 * AppIcon.filletRadius) - offset, y: 0 + offset), radius: AppIcon.filletRadius, startAngle: .degrees(0), endAngle: .degrees(270), clockwise: true)

        path.closeSubpath()
        return path.strokedPath(.init(lineWidth: 15))
    }
}

struct AppIcon: View {
    static let appIconSize: CGFloat = 1024

    static let maincolor: Color = .init(hex: 0x173C1C)
    static let maincolortint2: Color = .init(hex: 0x456349)

    static let outlineColor: Color = .init(hex: 0x389144)
    static let outlineColortint2: Color = .init(hex: 0x60A769)
    static let outlineColortint4: Color = .init(hex: 0x88BD8F)

    static let bigDotRadius: CGFloat = 120
    static let cornerDotRadius: CGFloat = 50
    static let filletRadius: CGFloat = 10

    var body: some View {
        ZStack {
            LinearGradient(colors: [AppIcon.outlineColortint4, AppIcon.outlineColortint2], startPoint: .top, endPoint: .bottom)
            IconShape()
                .fill(LinearGradient(colors: [AppIcon.maincolortint2, AppIcon.maincolor], startPoint: .top, endPoint: .bottom))
                .shadow(radius: 20)
            IconShape2()
                .fill(LinearGradient(colors: [AppIcon.outlineColortint2, AppIcon.outlineColor], startPoint: .top, endPoint: .bottom))
                .shadow(radius: 20)
            LinearGradient(colors: [AppIcon.outlineColortint4, AppIcon.outlineColor], startPoint: .top, endPoint: .bottom)
                .mask(Text("P")
                    .font(Font.system(size: 500, weight: .bold))
                    .italic()
                    .offset(x: -50, y: -150)
                )
                .shadow(radius: 20)

            LinearGradient(colors: [AppIcon.outlineColortint4, AppIcon.outlineColor], startPoint: .top, endPoint: .bottom)
                .mask(Text("K")
                    .font(Font.system(size: 500, weight: .bold))
                    .italic()
                    .offset(x: 50, y: 150)
                )
                .shadow(radius: 20)
        }.frame(width: AppIcon.appIconSize, height: AppIcon.appIconSize)
    }
}

#Preview {
    AppIcon()
        .previewLayout(.fixed(width: AppIcon.appIconSize,
                              height: AppIcon.appIconSize))
}
