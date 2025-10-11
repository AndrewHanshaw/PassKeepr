import SwiftUI

struct PrimaryTextFieldGeneric: View {
    @EnvironmentObject var modelData: ModelData

    var placeholderColor: Color
    @Binding var textLabel: String
    @Binding var text: String

    var textColor: Color
    var labelColor: Color

    @State private var textSize: CGSize = CGSizeZero
    @State private var showHelpPopover = false
    @State private var isCustomizeTextPresented = false

    var body: some View {
        ZStack {
            if textLabel != "" || text != "" {
                HStack {
                    Text(textLabel)
                        .frame(maxHeight: .infinity, alignment: .top)
                        .foregroundColor(labelColor)
                        .disableAutocorrection(true)
                        .textCase(.uppercase)
                        .font(.system(size: 12))
                        .padding(0)
                        .padding(.top, -2)
                    Spacer()
                }

                HStack {
                    Text(text)
                        .frame(maxHeight: .infinity, alignment: .bottom)
                        .foregroundColor(textColor)
                        .disableAutocorrection(true)
                        .font(.system(size: 30))
                        .padding(0)
                        .padding(.bottom, -6)
                    Spacer()
                }
            } else {
                RoundedRectangle(cornerRadius: 5)
                    .stroke(style: StrokeStyle(lineWidth: 2, dash: [5, 3]))
                    .foregroundColor(placeholderColor)
                    .opacity(placeholderColor == Color.gray ? 0.5 : 0.3)
                    .frame(maxHeight: .infinity)
                    .aspectRatio(2, contentMode: .fit)
                    .readSize(into: $textSize)
                Text("Primary\nField")
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.34)
                    .foregroundColor(placeholderColor)
                    .opacity(placeholderColor == Color.gray ? 0.7 : 0.4)
                    .padding(2)
                    .frame(maxWidth: textSize.width)
            }

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

            HStack {
                Spacer()
                VStack {
                    Spacer()
                    Image(systemName: "pencil.circle.fill")
                        .opacity(0)
                        .font(.system(size: 18))
                        .popover(isPresented: $showHelpPopover, arrowEdge: .top) {
                            Group {
                                Text("Tap on icons\nto edit each field")
                                    .multilineTextAlignment(.center)
                                    .presentationCompactAdaptation((.popover))
                                Button(action: { showHelpPopover = false; print("popover 0 dismissed") }) {
                                    Text("Ok")
                                        .foregroundColor(.white)
                                        .padding(5)
                                        .background(Color.accentColor)
                                        .cornerRadius(5)
                                }
                            }
                            .padding(5)
                        }
                        .onChange(of: showHelpPopover) {
                            print("Popover was dismissed")
                            modelData.tutorialStage += 1
                        }
                }
            }
            .offset(x: 9, y: 9)
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
    PrimaryTextFieldGeneric(placeholderColor: Color.black, textLabel: .constant("HEADER"), text: .constant("TEST"), textColor: .black, labelColor: .black)
}
