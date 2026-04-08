import SwiftUI

struct PrimaryTextFieldGeneric: View {
    @EnvironmentObject var modelData: ModelData

    var backgroundBrightness: BackgroundBrightness
    var disableButton: Bool

    @Binding var textLabel: String
    @Binding var text: String
    @Binding var passObject: PassObject
    @Binding var isCustomizeThumbnailImagePresented: Bool

    var textColor: Color
    var labelColor: Color

    @State private var textSize: CGSize = CGSizeZero
    @State private var showHelpPopover = false
    @State private var isCustomizeTextPresented = false

    var body: some View {
        HStack {
            Group {
                if textLabel != "" || text != "" {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(textLabel)
                            .frame(alignment: .topLeading)
                            .foregroundColor(labelColor)
                            .disableAutocorrection(true)
                            .textCase(.uppercase)
                            .font(.system(size: 11))
                            .lineLimit(1)
                            .fontWeight(.semibold)
                            .padding(0)
                            .padding(.top, 0)

                        Text(text)
                            .frame(alignment: .topLeading)
                            .foregroundColor(textColor)
                            .disableAutocorrection(true)
                            .font(.system(size: 30))
                            .lineLimit(2)
                            .padding(0)
                            .padding(.bottom, -4)
                            .minimumScaleFactor(0.34)
                            .layoutPriority(1)
                    }
                    // .padding(.bottom, 30) // TODO: figure out how to only apply if there is 1 line of text.
                    // Doing this https://medium.com/@kieraj_82811/counting-the-number-of-rendered-lines-in-swiftui-text-1151c4ba8a72 does not work
                    // I get "Bound preference LayoutKey tried to update multiple times per frame" upon initial draw
                    .layoutPriority(1)
                } else {
                    ZStack {
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(style: StrokeStyle(lineWidth: 2, dash: [5, 3]))
                            .foregroundColor(backgroundBrightness.overwriteForegroundColor)
                            .opacity(backgroundBrightness.overwriteOpacityRoundedRectangle)
                        Text("Primary\nField")
                            .multilineTextAlignment(.center)
                            .minimumScaleFactor(0.34)
                            .foregroundColor(backgroundBrightness.overwriteForegroundColor)
                            .opacity(backgroundBrightness.overwriteOpacity)
                            .padding(2)
                    }
                }
            }
            .popover(isPresented: $isCustomizeTextPresented, arrowEdge: .leading) {
                CustomizePassTextField(textLabel: $textLabel, text: $text)
                    .presentationCompactAdaptation((.popover))
            }
            .overlay(alignment: .bottomTrailing) {
                Button(action: {
                    isCustomizeTextPresented.toggle()
                }) {
                    Image(systemName: "pencil.circle.fill")
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.green, .white)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                        .font(.system(size: 18))
                        .shadow(radius: 3, x: 0, y: 0)
                }
                .offset(x: 9, y: 9)
                .buttonStyle(PlainButtonStyle())
                .disabled(disableButton)
            }
            .popover(isPresented: $showHelpPopover, attachmentAnchor: .point(.bottomTrailing), arrowEdge: .top) {
                Group {
                    Text("Tap on icons\nto edit each field")
                        .multilineTextAlignment(.center)
                    Button("Ok", action: { showHelpPopover = false; print("popover 0 dismissed") })
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .accentColorProminentButtonStyleIfAvailable()
                }
                .popoverModifier()
                .presentationCompactAdaptation(.popover)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.trailing, 10)

            ThumbnailImageView(backgroundBrightness: backgroundBrightness, disableButton: disableButton, passObject: $passObject, isCustomizeThumbnailImagePresented: $isCustomizeThumbnailImagePresented)
                .aspectRatio(1, contentMode: .fit)
                .padding(4)
                .padding(.trailing, 7)
        }
        .onChange(of: showHelpPopover) {
            print("Popover was dismissed")
            modelData.tutorialStage += 1
        }
        .onAppear {
            showHelpPopover = modelData.tutorialStage == 0
        }
    }
}

#Preview {
    PrimaryTextFieldGeneric(backgroundBrightness: .normal, disableButton: false, textLabel: .constant("HEADER"), text: .constant("TEST"), passObject: .constant(MockModelData().passObjects[0]), isCustomizeThumbnailImagePresented: .constant(false), textColor: .black, labelColor: .black)
}
