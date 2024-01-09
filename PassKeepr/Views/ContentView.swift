import SwiftUI

struct ContentView: View {
    @Environment(ModelData.self) var modelData

    @State var shouldPresentSheet = false

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
                    .navigationTitle("All Passes")
                }
                HStack {
                    Spacer()
                    Button(role: .none,
                           action: {shouldPresentSheet.toggle()},
                           label: {
                            Image(systemName:"plus.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50)
                           }
                    )
                    .labelStyle(.iconOnly)
                    .padding([.trailing], 33)
                    .sheet(isPresented: $shouldPresentSheet) {
                        AddPass(isSheetPresented: $shouldPresentSheet)
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .environment(ModelData())
}
