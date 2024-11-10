import PassKit
import SwiftUI

struct AddPass: View {
    @Environment(ModelData.self) var modelData
    @StateObject var passSigner: pkPassSigner = .init()

    @State private var enableHeaderField = false
    @State private var headerFieldLabel = ""
    @State private var headerFieldText = ""

    @State private var addedPass = PassObject()
    @State private var addedPKPass = PKPass()

    @Binding var isSheetPresented: Bool // Used to close the sheet in the parent view
    @State var isWalletSheetPresented: Bool = false // Used to close the sheet in the parent view
    @State private var isDoneSigningPass: Bool = false
    @State private var hasAddPassButtonBeenPressed = false

    var body: some View {
        VStack {
            Form {
                List {
                    Section {
                        LabeledContent {
                            TextField(
                                "Name",
                                text: $addedPass.passName
                            )
                        } label: {
                            Text("Pass Name")
                        }
                        .disableAutocorrection(true)

                        Picker("Pass Type", selection: $addedPass.passType) {
                            ForEach(PassType.allCases) { type in
                                HStack {
                                    Text(PassObjectHelpers.GetStringSingular(type))
                                    Image(systemName: PassObjectHelpers.GetSystemIcon(type))
                                }.tag(type)
                            }
                        }
                    } header: {
                        Text("Add a Pass:")
                            .font(.system(size: 25, weight: .bold, design: .rounded))
                            .textCase(nil)
                            .padding(.bottom, 4)
                            .padding(.top, 8)
                    }

                    PassInput(pass: $addedPass)

                    Section {
                        Button(
                            action: {
                                hasAddPassButtonBeenPressed = true // Set flag so we can disable the button once pressed
                                addedPass.passName == "" ? addedPass.passName = "Default Name" : ()
                                modelData.PassObjects.append(addedPass)
                                modelData.encodePassObjects() // need to modify to only encode variables that are relevant based on PassType

                                // TODO: Indicate why generation was unsuccessful if it fails
                                if let pkpassDir = generatePass(passObject: addedPass) {
                                    Task {
                                        passSigner.uploadPKPassFile(fileURL: pkpassDir, passUuid: addedPass.id)
                                    }
                                    isWalletSheetPresented = true
                                }
                            }) {
                                ZStack {
                                    ProgressView()
                                        .tint(.white)
                                        .padding(.leading, 110)
                                        .opacity(hasAddPassButtonBeenPressed && !passSigner.isDataLoaded ? 1 : 0) // Fade-in effect
                                        .animation(.easeInOut(duration: 0.2), value: hasAddPassButtonBeenPressed && !passSigner.isDataLoaded)
                                    HStack {
                                        Spacer()
                                        Text("Add Pass")
                                            .fontWeight(.bold)
                                            .foregroundColor(Color.white)
                                        Spacer()
                                    }
                                }
                            }
                            .disabled(hasAddPassButtonBeenPressed)
                            .opacity(hasAddPassButtonBeenPressed ? 0.4 : 1.0)
                            .animation(.easeInOut(duration: 0.2), value: hasAddPassButtonBeenPressed)
                    } footer: {
                        HStack {
                            Spacer()
                            Text("Optional Customizations:")
                                .font(.system(size: 20))
                            Spacer()
                        }
                        .padding(.bottom, -999)
                        .padding(.top, 20)
                    } // Section
                    .listRowBackground(Color.accentColor)

                    ColorInput(pass: $addedPass)

                    LogoImagePicker(passObject: $addedPass)

                    AdditionalFieldInput(enableHeaderField: $enableHeaderField, labelInput: $headerFieldLabel, textInput: $headerFieldText)
                } // List
                .listSectionSpacing(20)
            } // Form
        } // VStack
        .scrollDismissesKeyboard(.immediately)
        .sheet(isPresented: $passSigner.isDataLoaded) {
            AddToWalletView(pass: getPkPass(fileURL: passSigner.fileURL!)) { wasAdded in
                if wasAdded {
                    print("Pass was successfully added to wallet")
                    isSheetPresented = false
                } else {
                    print("Pass was not added to wallet")
                }

                hasAddPassButtonBeenPressed = false // Disable loading circle
            }
        }
    } // View
} // Struct

func getPkPass(fileURL: URL) -> PKPass {
    do {
        return try PKPass(data: Data(contentsOf: fileURL))
    } catch {
        return PKPass()
    }
}

#Preview {
    AddPass(isSheetPresented: .constant(true))
        .environment(MockModelData())
}
