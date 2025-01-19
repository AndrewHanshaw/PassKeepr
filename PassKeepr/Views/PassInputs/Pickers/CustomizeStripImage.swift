import _PhotosUI_SwiftUI
import CoreImage
import SwiftUI

struct CustomizeStripImage: View {
    @Binding var passObject: PassObject
    @State private var cropOffset: CGFloat = 0.0
    @State private var size: CGSize = CGSizeZero
    @State private var offsetBound: CGFloat = 0

    @State private var tempStrip: UIImage?

    @State private var photoItem: PhotosPickerItem?

    @State private var showAlert: Bool = false

    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    init(passObject: Binding<PassObject>) {
        _passObject = passObject
        _tempStrip = State(initialValue: UIImage(data: passObject.wrappedValue.stripImage))
    }

    var body: some View {
        List {
            Section {
                ZStack {
                    PhotosPicker("Choose Strip Image", selection: $photoItem, matching: .any(of: [.images, .not(.videos)]))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .onChange(of: photoItem) {
                            Task {
                                if let loaded = try? await photoItem?.loadTransferable(type: Data.self) {
                                    tempStrip = UIImage(data: loaded)!
                                } else {
                                    print("Failed")
                                }
                            }
                        }
                }
            }
            header: {
                if let strip = tempStrip {
                    OffsetCroppedStripImage(cropOffset: cropOffset, strip: strip)
                        .readSize(into: $size)
                        .padding([.top, .bottom], 20)
                        .onAppear {
                            offsetBound = (((size.width / strip.size.width) * strip.size.height) - size.height) / 2 // Scale the image so it's the same width as the rectangle, then subtract the height difference to get the quantity of vertical pts that are cropped out. Then diviide that by 2 so the offset can go +/- that value
                            print("offsetBound \(offsetBound)")
                        }
                        .onChange(of: strip) {
                            Task {
                                offsetBound = (((size.width / strip.size.width) * strip.size.height) - size.height) / 2
                                cropOffset = 0
                                print("cropOffset \(cropOffset)")
                            }
                        }
                }
            }

            if offsetBound > 1 { // if the selected strip image is already the correct aspect ratio, don't show the adjustment slider
                Section {
                    HStack {
                        Text("Vertical Offset")
                        Slider(value: $cropOffset, in: -offsetBound ... offsetBound, step: 1)
                            .padding()
                    }
                }
            }

            Section {
                Button(role: .destructive) {
                    passObject.stripImage = Data()
                    presentationMode.wrappedValue.dismiss()
                }
                label: {
                    Text("Remove Strip Image")
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }

            Section {
                Button(
                    action: {
                        if let strip = tempStrip {
                            let imageWidth = 1125.0
                            let imageHeight = 432.0

                            passObject.stripImage = ImageRenderer(content:
                                OffsetCroppedStripImage(cropOffset: cropOffset * imageHeight / size.height /* must scale cropOffset by the ratio between this rendered larger view and the original view */, strip: strip).frame(width: imageWidth, height: imageHeight)
                            ).uiImage?.pngData() ?? Data()
                        }
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Save")
                            .fontWeight(.bold)
                            .foregroundColor(Color.white)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
            }
            .listRowBackground(Color.accentColor)
        }
    }
}

#Preview {
    CustomizeStripImage(passObject: .constant(MockModelData().passObjects[0]))
}
