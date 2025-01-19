import SwiftUI
import UniformTypeIdentifiers

struct About: View {
    @EnvironmentObject var modelData: ModelData

    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    @State private var isDocumentPickerPresented: Bool = false
    @State private var isInfoPagePresented: Bool = false
    @State private var showIcon = false
    @State private var iconSize: CGSize = CGSizeZero

    var body: some View {
        VStack {
            Spacer()
            Image("passkeepr.icon")
                .resizable()
                .scaledToFit()
                .readSize(into: $iconSize)
                .clipShape(RoundedRectangle(cornerRadius: iconSize.width * 0.2, style: .continuous))
                .shadow(radius: 5)
                .padding([.top, .leading, .trailing], 100)
            Text("PassKeepr")
            Text("Version \(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "Unknown")")
            Spacer()
            Text("Created by Drew Hanshaw")
            Link(destination: URL(string: "https://x.com/drew_some1")!) {
                HStack {
                    Text("Follow me on")
                        .frame(height: 30)
                        .foregroundColor(Color.white)
                    Image("x.logo.white")
                        .resizable()
                        .scaledToFit()
                        .padding([.top, .bottom], 5)
                        .frame(height: 30)
                }
                .padding(8)
                .frame(maxHeight: 30)
                .background(RoundedRectangle(cornerRadius: 5)
                    .foregroundColor(Color.accentColor)
                )
            }
        }
    }
}

#Preview {
    About()
}
