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
                            .frame(maxHeight: .infinity, alignment: .topLeading)
                            .foregroundColor(labelColor)
                            .disableAutocorrection(true)
                            .textCase(.uppercase)
                            .font(.system(size: 11))
                            .fontWeight(.semibold)
                            .padding(0)
                            .padding(.top, 0)

                        Text(text)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                            .foregroundColor(textColor)
                            .disableAutocorrection(true)
                            .font(.system(size: 30))
                            .lineLimit(nil)
                            .padding(0)
                            .padding(.bottom, -4)
                            .layoutPriority(1)
                    }
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
                    .padding([.top, .bottom], 10)
                }
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
            .frame(maxWidth: .infinity)
            .padding(.trailing, 10)

            ThumbnailImageView(backgroundBrightness: backgroundBrightness, disableButton: disableButton, passObject: $passObject, isCustomizeThumbnailImagePresented: $isCustomizeThumbnailImagePresented)
                .padding(4)
                .padding(.trailing, 7)
                .aspectRatio(1, contentMode: .fit)
                .border(Color.blue)
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
        .onChange(of: showHelpPopover) {
            print("Popover was dismissed")
            modelData.tutorialStage += 1
        }

        .popover(isPresented: $isCustomizeTextPresented, arrowEdge: .leading) {
            CustomizePassTextField(textLabel: $textLabel, text: $text)
                .presentationCompactAdaptation((.popover))
        }
        .onAppear {
            showHelpPopover = modelData.tutorialStage == 0
        }
    }
}

#Preview {
    PrimaryTextFieldGeneric(backgroundBrightness: .normal, disableButton: false, textLabel: .constant("HEADER"), text: .constant("TEST"), passObject: .constant(MockModelData().passObjects[0]), isCustomizeThumbnailImagePresented: .constant(false), textColor: .black, labelColor: .black)
}
