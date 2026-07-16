import SwiftUI

struct LandscapeDetailPane: View {
    var body: some View {
        ContentUnavailableView(
            "Select a Pass to Edit,\nor Add a New Pass",
            systemImage: "wallet.pass"
        )
    }
}
