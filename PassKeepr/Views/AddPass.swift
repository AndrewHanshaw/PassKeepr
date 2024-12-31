import PassKit
import SwiftUI

struct AddPass: View {
    @EnvironmentObject var modelData: ModelData

    @EnvironmentObject var passSigner: pkPassSigner

    @State private var addedPass = PassObject()
    @State private var addedPKPass = PKPass()

    @Binding var isSheetPresented: Bool // Used to close the sheet in the parent view
    @State var isWalletSheetPresented: Bool = false // Used to close the sheet in the parent view
    @State private var isDoneSigningPass: Bool = false
    @State private var hasAddPassButtonBeenPressed = false
    @State private var textSize: CGSize = CGSizeZero

    var body: some View {
        VStack {
            Form {
                List {
                    Section {
                        Picker("Barcode Type", selection: $addedPass.barcodeType) {
                            ForEach(BarcodeType.allCases) { type in
                                HStack {
                                    Text(type.description)
                                    if type == BarcodeType.none {
                                        Image(systemName: "rectangle.portrait.on.rectangle.portrait.angled")
                                    } else if type == BarcodeType.none {
                                        Image(systemName: "qrcode")
                                    } else {
                                        Image(systemName: "barcode")
                                    }
                                }.tag(type)
                            }
                        }
                    }
                    header: { // Slightly hacky way to get a custom view into a Form/List without having to adhere to the typical styling of the Form/List
                        EditablePassCard(passObject: $addedPass)
                            .textCase(nil) // Otherwise all text within the view will be all caps
                            .listRowInsets(.init(top: 40,
                                                 leading: 0,
                                                 bottom: 40,
                                                 trailing: 0))
                            .listRowBackground(Color.clear)
                    }

                    Section {
                        Button(
                            action: {
                                hasAddPassButtonBeenPressed = true // Set flag so we can disable the button once pressed
                                addedPass.primaryFieldText == "" ? addedPass.primaryFieldText = "Default" : ()
                                modelData.passObjects.append(addedPass)
                                modelData.encodePassObjects()

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
                                        .opacity(hasAddPassButtonBeenPressed && !passSigner.isDataLoaded ? 1 : 0)
                                        .animation(.easeInOut(duration: 0.2), value: hasAddPassButtonBeenPressed && !passSigner.isDataLoaded)
                                        .offset(x: textSize.width / 2 + 20)
                                    HStack {
                                        Spacer()
                                        Text("Add Pass")
                                            .fontWeight(.bold)
                                            .foregroundColor(Color.white)
                                            .readSize(into: $textSize)
                                        Spacer()
                                    }
                                }
                            }
                            .disabled(hasAddPassButtonBeenPressed)
                            .opacity(hasAddPassButtonBeenPressed ? 0.4 : 1.0)
                            .animation(.easeInOut(duration: 0.2), value: hasAddPassButtonBeenPressed)
                    }
                    .listRowBackground(Color.accentColor)
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
