import SwiftUI

struct ContentView: View {
    @Environment(ModelData.self) var modelData
    
    var body: some View {
        NavigationView{
            VStack {
                List {
                    ListSection(modelData: _modelData)
                    .navigationTitle("All Passes")
                }
                HStack {
                    Spacer()
                    
                    NavigationLink(destination: Text("Add Content")) {
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
