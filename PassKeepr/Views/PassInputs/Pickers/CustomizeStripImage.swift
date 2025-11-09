import _PhotosUI_SwiftUI
import CoreImage
import SwiftUI

struct CustomizeStripImage: View {
    @Environment(\.colorScheme) var colorScheme

    var placeholderColor: Color
    @Binding var passObject: PassObject
    @State private var cropOffset: CGFloat = 0.0
    @State private var size: CGSize = CGSizeZero
    @State private var offsetBound: CGFloat = 0

    @State private var tempStrip: UIImage?

    @State private var photoItem: PhotosPickerItem?

    @State private var showAlert: Bool = false

    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    init(passObject: Binding<PassObject>, placeholderColor: Color) {
        self.placeholderColor = placeholderColor
        _passObject = passObject
        _tempStrip = State(initialValue: UIImage(data: passObject.wrappedValue.stripImage))
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
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
                } else {
                    ZStack {
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(style: StrokeStyle(lineWidth: 2, dash: [5, 3]))
                            .aspectRatio(1125 / 432, contentMode: .fit)
                            .foregroundColor(Color.gray)
                            .opacity(0.5)
                        Text("Add a Strip Image")
                            .scaledToFit()
                            .textCase(nil)
                            .foregroundColor(Color.gray)
                            .opacity(0.7)
                    }
                    .padding([.top, .bottom], 20)
                    .frame(maxWidth: .infinity, alignment: .center)
                }

                PhotosPicker(selection: $photoItem, matching: .any(of: [.images, .not(.videos)])) {
                    Text(tempStrip == nil ? "Select a Strip Image" : "Change Strip Image")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .foregroundColor(Color.white)
                        .padding(.vertical, 12)
                        .accentColorProminentButtonStyleIfAvailable()
                }
                .onChange(of: photoItem) {
                    Task {
                        if let loaded = try? await photoItem?.loadTransferable(type: Data.self) {
                            tempStrip = UIImage(data: loaded)!
                        } else {
                            print("Failed")
                        }
                    }
                }

                if offsetBound > 1 { // if the selected strip image is already the correct aspect ratio, don't show the adjustment slider
                    HStack {
                        Text("Vertical Offset")
                        Slider(value: $cropOffset, in: -offsetBound ... offsetBound, step: 1)
                    }
                    .padding(14)
                    .listSectionBackgroundModifier()
                }

                if tempStrip != nil {
                    Button(role: .destructive) {
                        passObject.stripImage = Data()
                        presentationMode.wrappedValue.dismiss()
                    }
                    label: {
                        Text("Remove Strip Image")
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .padding([.top, .bottom], 12)
                    .listSectionBackgroundModifier()
                }

                Spacer()
            }
            .padding()
            .background(colorScheme == .light ? Color(UIColor.secondarySystemBackground) : Color(UIColor.systemBackground))
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Strip Image")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", systemImage: "checkmark") {
                        if let strip = tempStrip {
                            let imageWidth = 1125.0
                            let imageHeight = 432.0

                            passObject.stripImage = ImageRenderer(content:
                                OffsetCroppedStripImage(cropOffset: cropOffset * imageHeight / size.height /* must scale cropOffset by the ratio between this rendered larger view and the original view */, strip: strip).frame(width: imageWidth, height: imageHeight)
                            ).uiImage?.pngData() ?? Data()
                            passObject.backgroundImage = Data()
                        }
                        presentationMode.wrappedValue.dismiss()
                    }
                    .toolbarConfirmButtonModifier()
                }

                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", systemImage: "xmark") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .toolbarCancelButtonModifier()
                }
            }
        }
    }
}

#Preview {
    CustomizeStripImage(passObject: .constant(MockModelData().passObjects[0]), placeholderColor: Color.black)
}
