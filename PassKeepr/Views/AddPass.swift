import SwiftUI

struct AddPass: View {
    @Environment(ModelData.self) var modelData

    @State private var logoImage = UIImage()
    @State private var enableHeaderField = false
    @State private var headerFieldLabel = ""
    @State private var headerFieldText = ""

    @State private var addedPass = PassObject()

    @Binding var isSheetPresented: Bool // Used to close the sheet in the parent view

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
                            .padding([.bottom])
                    }

                    PassInput(pass: $addedPass)

                    Section {
                        Button(
                            action: {
                                addedPass.passName == "" ? addedPass.passName = "Default Name" : ()
                                modelData.PassObjects.append(addedPass)
                                modelData.encodePassObjects() // need to modify to only encode variables that are relevant based on PassType

                                // TODO: Indicate why generation was unsuccessful if it fails
                                if let pkpassDir = generatePass(passObject: addedPass) {
                                    pkPassSigner().uploadPKPassFile(fileURL: pkpassDir, passUuid: addedPass.id)
                                    isSheetPresented = false
                                }
                            },
                            label: {
                                HStack {
                                    Spacer()
                                    Text("Add Pass")
                                        .fontWeight(.bold)
                                        .foregroundColor(Color.white)
                                    Spacer()
                                }
                            }
                        ) // Button
                    } footer: {
                        HStack {
                            Spacer()
                            Text("Optional Customizations:")
                                .font(.system(size: 20))
                            Spacer()
                        }
                        .padding(.bottom, -999)
                        .padding(.top, 10)
                    } // Section
                    .listRowBackground(Color.accentColor)

                    ColorInput(pass: $addedPass)

                    LogoImagePicker(selectedImage: $logoImage)

                    AdditionalFieldInput(enableHeaderField: $enableHeaderField, labelInput: $headerFieldLabel, textInput: $headerFieldText)
                } // List
                .listSectionSpacing(30)
            } // Form
        } // VStack
        .scrollDismissesKeyboard(.immediately)
    } // View
} // Struct

#Preview {
    AddPass(isSheetPresented: .constant(true))
        .environment(MockModelData())
}
