//
//  PassCard.swift
//  PassKeepr
//
//  Created by Andrew Hanshaw on 11/19/24.
//

import SwiftUI

struct PassCard: View {
    @EnvironmentObject var modelData: ModelData

    @State var passObject: PassObject
    @State var shouldPresentEditPass = false
    @State private var isObjectEdited = false
    @State private var isDragging = false

    @State private var showContextMenu = false
    @GestureState private var isDetectingLongPress = false

    var longPress: some Gesture {
        LongPressGesture(minimumDuration: 0.5)
            .updating($isDetectingLongPress) { currentState, gestureState, _ in
                gestureState = currentState
            }
            .onEnded { _ in
                showContextMenu = true
            }
    }

    var body: some View {
        VStack {
            Button(action: {
                shouldPresentEditPass.toggle()
            }) {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(passObject.backgroundImage != Data() ?
                        Color.clear : Color(hex: passObject.backgroundColor)
                    )
                    .background(
                        passObject.backgroundImage != Data() ?
                            Image(uiImage: UIImage(data: passObject.backgroundImage)!)
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .blur(radius: 6)
                            : nil // No background if image is nil
                    )
                    .clipShape(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                    )
                    .overlay(
                        VStack {
                            if passObject.logoImage != Data() {
                                HStack {
                                    Image(uiImage: UIImage(data: passObject.logoImage)!)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(maxHeight: 30)
                                        .padding([.top, .leading], 15)
                                    Spacer()
                                }
                            }
                            HStack {
                                Text("\(passObject.passName)")
                                    .foregroundColor(.white)
                                    .fontWeight(.bold)
                                    .padding([.bottom, .leading], 10)
                                Spacer()
                            }
                            Spacer()
                            if passObject.stripImage != Data() {
                                Image(uiImage: UIImage(data: passObject.stripImage)!)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxWidth: .infinity)
                                Spacer()
                            }
                        }
                    )
            }
            .sheet(isPresented: $shouldPresentEditPass) {
                EditPass(objectToEdit: $passObject, isObjectEdited: $isObjectEdited)
                    .presentationDragIndicator(.visible)
            }
            .gesture(longPress)
            .contextMenu {
                Button(action: {
                    shouldPresentEditPass.toggle()
                }) {
                    Label("Edit", systemImage: "pencil")
                }

                Button(action: {
                    print("Share")
                }) {
                    Label("Share", systemImage: "square.and.arrow.up")
                }

                Button(action: {
                    modelData.passObjects.append(passObject.duplicate())
                    modelData.encodePassObjects()
                }) {
                    Label("Duplicate", systemImage: "rectangle.portrait.on.rectangle.portrait")
                }

                Button(role: .destructive, action: {
                    modelData.deleteItemByID(passObject.id)
                }) {
                    Label("Delete", systemImage: "trash")
                }
            }
        }
    }
}

#Preview {
    PassCard(passObject: MockModelData().passObjects[0])
}
