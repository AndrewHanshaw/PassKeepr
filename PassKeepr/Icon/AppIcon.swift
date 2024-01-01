//
//  AppIcon.swift
//  PassKeepr
//
//  Created by Andrew Hanshaw on 12/27/23.
//

import SwiftUI

extension Color {
    init(hex: UInt, alpha: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255.0,
            green: Double((hex >> 8) & 0xFF) / 255.0,
            blue: Double(hex & 0xFF) / 255.0,
            opacity: alpha
        )
    }
}

struct IconShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        path.addArc(center: CGPoint(x: AppIcon.cornerDotRadius+2*AppIcon.filletRadius, y:0), radius: AppIcon.filletRadius, startAngle: .degrees(270), endAngle: .degrees(180), clockwise: true)

        // Top left corner
        path.addArc(center: CGPoint(x: AppIcon.filletRadius, y:AppIcon.filletRadius), radius: AppIcon.cornerDotRadius, startAngle: .degrees(0), endAngle: .degrees(90), clockwise: false)

        path.addArc(center: CGPoint(x: AppIcon.filletRadius, y:AppIcon.cornerDotRadius+2*AppIcon.filletRadius), radius: AppIcon.filletRadius, startAngle: .degrees(270), endAngle: .degrees(180), clockwise: true)

        path.addArc(center: CGPoint(x: AppIcon.filletRadius, y:(AppIcon.appIconSize/2)-(AppIcon.bigDotRadius+AppIcon.filletRadius)), radius: AppIcon.filletRadius, startAngle: .degrees(180), endAngle: .degrees(90), clockwise: true)

        // Left middle
        path.addArc(center: CGPoint(x: AppIcon.filletRadius, y:AppIcon.appIconSize/2), radius: AppIcon.bigDotRadius, startAngle: .degrees(270), endAngle: .degrees(90), clockwise: false)

        path.addArc(center: CGPoint(x: AppIcon.filletRadius, y:AppIcon.appIconSize-((AppIcon.appIconSize/2)-(AppIcon.bigDotRadius+AppIcon.filletRadius))), radius: AppIcon.filletRadius, startAngle: .degrees(270), endAngle: .degrees(180), clockwise: true)

        path.addArc(center: CGPoint(x: AppIcon.filletRadius, y:AppIcon.appIconSize-(AppIcon.cornerDotRadius+AppIcon.filletRadius)), radius: AppIcon.filletRadius, startAngle: .degrees(180), endAngle: .degrees(90), clockwise: true)

        // Bottom left corner
        path.addArc(center: CGPoint(x: AppIcon.filletRadius, y:AppIcon.appIconSize), radius: AppIcon.cornerDotRadius, startAngle: .degrees(270), endAngle: .degrees(0), clockwise: false)

        path.addArc(center: CGPoint(x: AppIcon.cornerDotRadius+2*AppIcon.filletRadius, y:AppIcon.appIconSize), radius: AppIcon.filletRadius, startAngle: .degrees(180), endAngle: .degrees(90), clockwise: true)

        path.addArc(center: CGPoint(x: AppIcon.appIconSize-(AppIcon.cornerDotRadius+2*AppIcon.filletRadius), y:AppIcon.appIconSize), radius: AppIcon.filletRadius, startAngle: .degrees(90), endAngle: .degrees(0), clockwise: true)

        // Bottom right corner
        path.addArc(center: CGPoint(x: AppIcon.appIconSize-AppIcon.filletRadius, y:AppIcon.appIconSize), radius: AppIcon.cornerDotRadius, startAngle: .degrees(180), endAngle: .degrees(270), clockwise: false)

        path.addArc(center: CGPoint(x: AppIcon.appIconSize-AppIcon.filletRadius, y:AppIcon.appIconSize-(AppIcon.cornerDotRadius+AppIcon.filletRadius)), radius: AppIcon.filletRadius, startAngle: .degrees(90), endAngle: .degrees(0), clockwise: true)

        path.addArc(center: CGPoint(x: AppIcon.appIconSize-AppIcon.filletRadius, y:AppIcon.appIconSize-((AppIcon.appIconSize/2)-(AppIcon.bigDotRadius+AppIcon.filletRadius))), radius: AppIcon.filletRadius, startAngle: .degrees(0), endAngle: .degrees(270), clockwise: true)

        // Right middle
        path.addArc(center: CGPoint(x: AppIcon.appIconSize-AppIcon.filletRadius, y:AppIcon.appIconSize/2), radius: AppIcon.bigDotRadius, startAngle: .degrees(90), endAngle: .degrees(270), clockwise: false)

        path.addArc(center: CGPoint(x: AppIcon.appIconSize-AppIcon.filletRadius, y:(AppIcon.appIconSize/2)-(AppIcon.bigDotRadius+AppIcon.filletRadius)), radius: AppIcon.filletRadius, startAngle: .degrees(90), endAngle: .degrees(0), clockwise: true)

        path.addArc(center: CGPoint(x: AppIcon.appIconSize-AppIcon.filletRadius, y:AppIcon.cornerDotRadius+2*AppIcon.filletRadius), radius: AppIcon.filletRadius, startAngle: .degrees(0), endAngle: .degrees(270), clockwise: true)

        // Top right corner
        path.addArc(center: CGPoint(x: AppIcon.appIconSize-AppIcon.filletRadius, y:AppIcon.filletRadius), radius: AppIcon.cornerDotRadius, startAngle: .degrees(90), endAngle: .degrees(180), clockwise: false)

        path.addArc(center: CGPoint(x: AppIcon.appIconSize-(AppIcon.cornerDotRadius+2*AppIcon.filletRadius), y:0), radius: AppIcon.filletRadius, startAngle: .degrees(0), endAngle: .degrees(270), clockwise: true)

        path.closeSubpath()

        return path
    }
}

struct IconShape2: Shape {
    func path(in rect: CGRect) -> Path {

        let offset: CGFloat = 100

        var path = Path()

        path.addArc(center: CGPoint(x: AppIcon.cornerDotRadius+2*AppIcon.filletRadius+offset, y:0+offset), radius: AppIcon.filletRadius, startAngle: .degrees(270), endAngle: .degrees(180), clockwise: true)

        path.addArc(center: CGPoint(x: AppIcon.filletRadius+offset, y:AppIcon.filletRadius+offset), radius: AppIcon.cornerDotRadius, startAngle: .degrees(0), endAngle: .degrees(90), clockwise: false)

        path.addArc(center: CGPoint(x: AppIcon.filletRadius+offset, y:AppIcon.cornerDotRadius+2*AppIcon.filletRadius+offset), radius: AppIcon.filletRadius, startAngle: .degrees(270), endAngle: .degrees(180), clockwise: true)

        path.addArc(center: CGPoint(x: AppIcon.filletRadius+offset, y:(AppIcon.appIconSize/2)-(AppIcon.bigDotRadius+AppIcon.filletRadius)-offset+26), radius: AppIcon.filletRadius, startAngle: .degrees(180), endAngle: .degrees(93), clockwise: true)

        // Left middle
        path.addArc(center: CGPoint(x: AppIcon.filletRadius, y:AppIcon.appIconSize/2), radius: AppIcon.bigDotRadius+offset, startAngle: .degrees(300), endAngle: .degrees(60), clockwise: false)

        path.addArc(center: CGPoint(x: AppIcon.filletRadius+offset, y:AppIcon.appIconSize-((AppIcon.appIconSize/2)-(AppIcon.bigDotRadius+AppIcon.filletRadius))+offset-26), radius: AppIcon.filletRadius, startAngle: .degrees(270), endAngle: .degrees(180), clockwise: true)

        path.addArc(center: CGPoint(x: AppIcon.filletRadius+offset, y:AppIcon.appIconSize-(AppIcon.cornerDotRadius+AppIcon.filletRadius)-offset), radius: AppIcon.filletRadius, startAngle: .degrees(180), endAngle: .degrees(90), clockwise: true)

        // Bottom left corner
        path.addArc(center: CGPoint(x: AppIcon.filletRadius+offset, y:AppIcon.appIconSize-offset), radius: AppIcon.cornerDotRadius, startAngle: .degrees(270), endAngle: .degrees(0), clockwise: false)

        path.addArc(center: CGPoint(x: AppIcon.cornerDotRadius+2*AppIcon.filletRadius+offset, y:AppIcon.appIconSize-offset), radius: AppIcon.filletRadius, startAngle: .degrees(180), endAngle: .degrees(90), clockwise: true)

        path.addArc(center: CGPoint(x: AppIcon.appIconSize-(AppIcon.cornerDotRadius+2*AppIcon.filletRadius)-offset, y:AppIcon.appIconSize-offset), radius: AppIcon.filletRadius, startAngle: .degrees(90), endAngle: .degrees(0), clockwise: true)

        // Bottom right corner
        path.addArc(center: CGPoint(x: AppIcon.appIconSize-AppIcon.filletRadius-offset, y:AppIcon.appIconSize-offset), radius: AppIcon.cornerDotRadius, startAngle: .degrees(180), endAngle: .degrees(270), clockwise: false)

        path.addArc(center: CGPoint(x: AppIcon.appIconSize-AppIcon.filletRadius-offset, y:AppIcon.appIconSize-(AppIcon.cornerDotRadius+AppIcon.filletRadius)-offset), radius: AppIcon.filletRadius, startAngle: .degrees(90), endAngle: .degrees(0), clockwise: true)

        path.addArc(center: CGPoint(x: AppIcon.appIconSize-AppIcon.filletRadius-offset, y:AppIcon.appIconSize-((AppIcon.appIconSize/2)-(AppIcon.bigDotRadius+AppIcon.filletRadius))+offset-26), radius: AppIcon.filletRadius, startAngle: .degrees(0), endAngle: .degrees(270), clockwise: true)

        // Right middle
        path.addArc(center: CGPoint(x: AppIcon.appIconSize-AppIcon.filletRadius, y:AppIcon.appIconSize/2), radius: AppIcon.bigDotRadius+offset, startAngle: .degrees(120), endAngle: .degrees(240), clockwise: false)

        path.addArc(center: CGPoint(x: AppIcon.appIconSize-AppIcon.filletRadius-offset, y:(AppIcon.appIconSize/2)-(AppIcon.bigDotRadius+AppIcon.filletRadius)-offset+26), radius: AppIcon.filletRadius, startAngle: .degrees(90), endAngle: .degrees(0), clockwise: true)

        path.addArc(center: CGPoint(x: AppIcon.appIconSize-AppIcon.filletRadius-offset, y:AppIcon.cornerDotRadius+2*AppIcon.filletRadius+offset), radius: AppIcon.filletRadius, startAngle: .degrees(0), endAngle: .degrees(270), clockwise: true)

        // Top right corner
        path.addArc(center: CGPoint(x: AppIcon.appIconSize-AppIcon.filletRadius-offset, y:AppIcon.filletRadius+offset), radius: AppIcon.cornerDotRadius, startAngle: .degrees(90), endAngle: .degrees(180), clockwise: false)

        path.addArc(center: CGPoint(x: AppIcon.appIconSize-(AppIcon.cornerDotRadius+2*AppIcon.filletRadius)-offset, y:0+offset), radius: AppIcon.filletRadius, startAngle: .degrees(0), endAngle: .degrees(270), clockwise: true)

        path.closeSubpath()
        return path.strokedPath(.init(lineWidth: 15))
    }
}

struct AppIcon: View {
    static let appIconSize: CGFloat = 1024

    static let maincolor: Color = Color(hex: 0x744981)
    static let tint1: Color = Color(hex: 0x744981)
    static let tint2: Color = Color(hex: 0x845d8f)
    static let tint3: Color = Color(hex: 0x93729d)
    
    static let outlineColor: Color = Color(hex: 0xcc93dc)
    static let outlineTint1: Color = Color(hex: 0xd19ee0)
    static let outlineTint2: Color = Color(hex: 0xd6a9e3)

    static let bigDotRadius: CGFloat = 120
    static let cornerDotRadius: CGFloat = 50
    static let filletRadius: CGFloat = 10

    var body: some View {
        ZStack {
            IconShape()
                .fill(LinearGradient(colors: [AppIcon.tint2, AppIcon.maincolor], startPoint: .top, endPoint: .bottom))
                .shadow(radius:5)
            IconShape2()
                .fill(LinearGradient(colors: [AppIcon.outlineTint2, AppIcon.outlineColor], startPoint: .top, endPoint: .bottom))
                .shadow(radius:5)
            LinearGradient(colors: [AppIcon.outlineTint2, AppIcon.outlineColor], startPoint: .top, endPoint: .bottom)
                .mask(Text("P")
                    .font(Font.system(size:500, weight: .bold))
                    .italic()
                    .offset(x:-50,y:-150)
                )
                .shadow(radius:5)

            LinearGradient(colors: [AppIcon.outlineTint2, AppIcon.outlineColor], startPoint: .top, endPoint: .bottom)
                .mask(Text("K")
                    .font(Font.system(size:500, weight: .bold))
                    .italic()
                    .offset(x:50,y:150)
                )
                .shadow(radius:5)
        }.frame(width: AppIcon.appIconSize, height: AppIcon.appIconSize)
    }
}

#Preview {
    AppIcon()
        .previewLayout(.fixed(width: AppIcon.appIconSize,
                              height: AppIcon.appIconSize))
}
