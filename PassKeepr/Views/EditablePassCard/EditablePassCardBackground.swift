//
//  EditablePassCardBackground.swift
//  PassKeepr
//
//  Created by Andrew Hanshaw on 12/15/24.
//

import SwiftUI

struct EditablePassCardBackground: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var passObject: PassObject

    var body: some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(passObject.backgroundImage != Data() ?
                Color.clear : Color(hex: passObject.backgroundColor)
            )
            .background(
                Group {
                    if passObject.backgroundImage != Data() {
                        AnyView(
                            Image(uiImage: UIImage(data: passObject.backgroundImage)!)
                                .resizable()
                                .scaleEffect(1.1) // Scale up the image slightly so that the clip shape doesn't pick up the white background. Otherwise there will be a white halo on the image
                                .blur(radius: 6)
                                .clipShape(
                                    RoundedRectangle(cornerRadius: 10)
                                )
                        )
                        .background(Color.clear)
                    } else {
                        AnyView(Color(hex: passObject.backgroundColor).clipShape(
                            RoundedRectangle(cornerRadius: 10)
                        ))
                    }
                }
            )
            .shadow(radius: 5, x: 0, y: 5)

        if passObject.backgroundImage != Data() {
            VStack {
                Circle()
                    .foregroundColor(colorScheme == .light ? Color(UIColor.secondarySystemBackground) : Color(UIColor.systemBackground))
                    .frame(width: 80)
                    .offset(y: -65)
                Spacer()
            }
        }
    }
}

#Preview {
    EditablePassCardBackground(passObject: .constant(MockModelData().passObjects[0]))
}
