import PassKit
import SwiftUI

struct AddPass: View {
    @EnvironmentObject var modelData: ModelData
    @State private var addedPass = PassObject()

    var body: some View {
        EditPass(objectToEdit: $addedPass)
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
    AddPass()
        .environment(MockModelData())
}
