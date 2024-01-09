import SwiftUI

struct ContentView: View {
    @Environment(ModelData.self) var modelData

    @State var shouldPresentAddPass = false
    @State var shouldPresentSettings = false

    var filteredList1: [ListItem] {
        modelData.listItems.filter { $0.passType == PassType.barcodePass }
    }
    
    var filteredList2: [ListItem] {
        modelData.listItems.filter { $0.passType == PassType.identificationPass }
    }
    
    var body: some View {
        NavigationView{
            VStack {
                List {
                    ListSection(list: filteredList1)
                    ListSection(list: filteredList2)
                }
                HStack {
                    Spacer()
                    Button(role: .none,
                           action: {shouldPresentAddPass.toggle()},
                           label: {
                            Image(systemName:"plus.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50)
                           }
                    )
                    .labelStyle(.iconOnly)
                    .padding([.trailing], 33)
                    .sheet(isPresented: $shouldPresentAddPass) {
                        AddPass(isSheetPresented: $shouldPresentAddPass)
                    }
                }
            }
            .background(Color(UIColor.secondarySystemBackground))
            .navigationBarTitleDisplayMode(.inline) // Necessary to prevent a gap between the title and the start of the list
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack {
                        Text("All Passes")
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                            .padding()
                        Spacer()
                        Button(role: .none,
                               action: {shouldPresentSettings.toggle()},
                               label: {
                                Image(systemName:"gearshape.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20)
                               }
                        )
                        .labelStyle(.iconOnly)
                        .sheet(isPresented: $shouldPresentSettings) {
                            Settings()
                        }
                    }
                }
            }
        }
        .navigationTitle("All Passes")
    }
}

#Preview {
    ContentView()
        .environment(ModelData(preview: true))
}
