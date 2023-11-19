import SwiftUI

struct ContentView: View {
    @Environment(ModelData.self) var modelData
    
    // TODO: Make this dynamic
    let maxType = 3
    
    var filteredList1: [ListItem] {
        modelData.listItems.filter { $0.type == 1 }
    }
    
    var filteredList2: [ListItem] {
        modelData.listItems.filter { $0.type == 2 }
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
                    
                    NavigationLink(destination: AddPass()) {
                        Image(systemName: "plus.circle.fill")
                            .font(.largeTitle)
                            .padding()
                            .foregroundColor(.accentColor)
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
