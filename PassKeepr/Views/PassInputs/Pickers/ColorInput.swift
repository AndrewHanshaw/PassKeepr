//
//  ColorInput.swift
//  PassKeepr
//
//  Created by Andrew Hanshaw on 1/27/24.
//

import SwiftUI

struct ColorInput: View {
    @Binding var bgColor: Color
    @Binding var fgColor: Color
    @Binding var textColor: Color

    var body: some View {
        VStack {
            ColorPicker("Background Color", selection: $bgColor)
                .padding(.top, 5)
            ColorPicker("Foreground Color", selection: $fgColor)
                .padding([.top, .bottom], 10)
            ColorPicker("Text Color", selection: $textColor)
                .padding(.bottom, 5)
        }
    }
}

#Preview {
    ColorInput(bgColor: .constant(Color.accentColor),
               fgColor: .constant(Color.accentColor),
               textColor: .constant(Color.accentColor))
}
