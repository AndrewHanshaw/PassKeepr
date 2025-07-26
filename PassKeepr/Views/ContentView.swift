import SwiftUI

private let PADDING: CGFloat = 10

struct ContentView: View {
    @EnvironmentObject var modelData: ModelData
    @EnvironmentObject var passSigner: pkPassSigner

    @State private var plusButtonSize: CGSize = CGSizeZero

    @State var shouldPresentAddPass = false
    @State var shouldPresentSettings = false

    @State private var active: PassObject?

    @StateObject private var dragProperties: DragProperties = .init()

    let columns: [GridItem] = Array(repeating: .init(.flexible(), spacing: PADDING), count: 2)

    var body: some View {
        NavigationView {
            ZStack {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: PADDING) {
                        @GestureState var isActive: Bool = false
                        ForEach($modelData.passObjects) { $passObject in
                            PassCardContainer(passObject: $passObject, isActive: isActive)
                                .aspectRatio(1 / 1.45, contentMode: .fill)
                                .background(Color.clear)
                        }
                        /* preview: { _ in
                             Circle()
                                 .frame(width: 1, height: 1)
                                 .opacity(0)
                         } moveAction: { from, to in
                              modelData.passObjects.move(fromOffsets: from, toOffset: to)
                              modelData.encodePassObjects()
                          } */
//                        .onMove { indices, newOffset in
//                            modelData.passObjects.move(fromOffsets: indices, toOffset: newOffset)
//                        }
                    }
                    .padding(PADDING)
                }
                .scrollDisabled(modelData.passObjects.isEmpty)
//                .reorderableForEachContainer(active: $active)
                .navigationBarTitleDisplayMode(.inline) // Necessary to prevent a gap between the title and the start of the grid
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        HStack {
                            Text("My Passes")
                                .font(.system(size: 30, weight: .bold, design: .rounded))
                                .padding()
                            Spacer()
                            Button(role: .none,
                                   action: { shouldPresentSettings.toggle() },
                                   label: {
                                       Image(systemName: "gearshape.fill")
                                           .resizable()
                                           .scaledToFit()
                                           .frame(width: 20)
                                   })
                                   .labelStyle(.iconOnly)
                                   .popover(isPresented: $shouldPresentSettings) {
                                       Settings()
                                           .presentationCompactAdaptation((.popover))
                                   }
                        }
                    }
                }
                VStack {
                    Spacer()
                    if modelData.passObjects.isEmpty {
                        Text("Use the ＋ Button\nto Add a Pass")
                            .font(Font.system(size: 24, weight: .bold, design: .rounded))
                            .padding([.trailing], plusButtonSize.width + 40)
                            .multilineTextAlignment(.trailing)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .padding(.bottom, -10)
                            .opacity(0.4)
                    }
                    HStack {
                        Spacer()
                        if modelData.passObjects.isEmpty {
                            Image(systemName: "arrow.turn.down.right")
                                .font(.system(size: 36))
                                .opacity(0.4)
                        }
                        Button(role: .none,
                               action: { shouldPresentAddPass.toggle() },
                               label: {
                                   Image(systemName: "plus.circle.fill")
                                       .resizable()
                                       .scaledToFit()
                                       .frame(width: 50)
                               })
                               .labelStyle(.iconOnly)
                               .padding([.trailing], 33)
                               .sheet(isPresented: $shouldPresentAddPass) {
                                   AddPass()
                                       .presentationDragIndicator(.visible)
                               }
                               .readSize(into: $plusButtonSize)
                    }
                }
            } // ZStack
        } // NavigationView
    }
}

struct PassCardContainer: View {
    @Binding var passObject: PassObject
    
    @EnvironmentObject private var properties: DragProperties
    @EnvironmentObject var modelData: ModelData
    @GestureState var isActive: Bool

    @State var shouldPresentEditPass = false

    var body: some View {
        PassCard(passObject: passObject)
            .onTapGesture {
                shouldPresentEditPass.toggle()
            }
            .sheet(isPresented: $shouldPresentEditPass) {
                EditPass(objectToEdit: $passObject)
                    .presentationDragIndicator(.visible)
            }
            .onDrag {
                print("onDrag started for: \(passObject.id.uuidString)")
                return NSItemProvider(object: NSString(string: passObject.id.uuidString))
            }
            .onDrop(of: [.text], delegate: PassDropDelegate(
                destinationItem: passObject,
                modelData: modelData
            ))
    }
}

// Drop delegate to handle the reordering logic
struct PassDropDelegate: DropDelegate {
    let destinationItem: PassObject
    let modelData: ModelData
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }
    
    func performDrop(info: DropInfo) -> Bool {
        guard let itemProvider = info.itemProviders(for: [.text]).first else {
            return false
        }
        
        itemProvider.loadItem(forTypeIdentifier: "public.text", options: nil) { (item, error) in
            guard let data = item as? Data,
                  let draggedIdString = String(data: data, encoding: .utf8),
                  let draggedId = UUID(uuidString: draggedIdString) else {
                return
            }
            
            DispatchQueue.main.async {
                // Find indices of the dragged and destination items
                guard let fromIndex = modelData.passObjects.firstIndex(where: { $0.id == draggedId }),
                      let toIndex = modelData.passObjects.firstIndex(where: { $0.id == destinationItem.id }) else {
                    return
                }
                
                // Perform the move
                let draggedItem = modelData.passObjects.remove(at: fromIndex)
                modelData.passObjects.insert(draggedItem, at: toIndex)
                
                // Save the changes
                modelData.encodePassObjects()
            }
        }
        
        return true
    }
    
    func dropEntered(info: DropInfo) {
        // Optional: Add visual feedback when drag enters this drop zone
    }
    
    func dropExited(info: DropInfo) {
        // Optional: Remove visual feedback when drag exits this drop zone
    }
}

#Preview {
    ContentView()
}
