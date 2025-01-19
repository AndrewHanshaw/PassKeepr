import SwiftUI

struct StripImageSelection: View {
    @Binding var passObject: PassObject

    var body: some View {
        Section {
            Toggle(isOn: $passObject.isCustomStripImageOn) {
                Text("Strip Image")
            }
            .onChange(of: passObject.isCustomStripImageOn) {
                Task {
                    passObject.passStyle = passObject.isCustomStripImageOn ? PassStyle.storeCard : PassStyle.generic
                    if passObject.isCustomStripImageOn == false {
                        passObject.stripImage = Data()
                    }
                }
            }
        }
    }
}

#Preview {
    StripImageSelection(passObject: .constant(ModelData().passObjects[0]))
}
