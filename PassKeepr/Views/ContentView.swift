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
        .environmentObject(dragProperties)
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
            .opacity(properties.draggedItem?.id == passObject.id ? 0.6 : 1.0)
            .scaleEffect(properties.currentHoverTarget?.id == passObject.id ? 1.02 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: properties.currentHoverTarget?.id)
            .animation(.easeInOut(duration: 0.2), value: properties.draggedItem?.id)
            .onTapGesture {
                shouldPresentEditPass.toggle()
            }
            .sheet(isPresented: $shouldPresentEditPass) {
                EditPass(objectToEdit: $passObject)
                    .presentationDragIndicator(.visible)
            }
            .onDrag {
                print("onDrag started for: \(passObject.id.uuidString)")
                properties.draggedItem = passObject
                return NSItemProvider(object: NSString(string: passObject.id.uuidString))
            }
            .onDrop(of: [.text], delegate: PassDropDelegate(
                destinationItem: passObject,
                modelData: modelData,
                dragProperties: properties
            ))
    }
}

struct PassDropDelegate: DropDelegate {
    let destinationItem: PassObject
    let modelData: ModelData
    let dragProperties: DragProperties
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }
    
    func performDrop(info: DropInfo) -> Bool {
        // Clean up drag state and save the final order
        defer {
            dragProperties.draggedItem = nil
            dragProperties.currentHoverTarget = nil
            
            // Save the final reordered state
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                modelData.encodePassObjects()
            }
        }
        
        // The array is already in the correct order from the live reordering
        // so we just need to confirm the drop was successful
        return true
    }
    
    func dropEntered(info: DropInfo) {
        guard let draggedItem = dragProperties.draggedItem,
              draggedItem.id != destinationItem.id else {
            return
        }
        
        // Update hover target for visual feedback
        dragProperties.currentHoverTarget = destinationItem
        
        // Perform real-time reordering of the actual array
        reorderPassObjects(draggedItem: draggedItem, destinationItem: destinationItem)
    }
    
    func dropExited(info: DropInfo) {
        // Clear hover target when exiting
        if dragProperties.currentHoverTarget?.id == destinationItem.id {
            dragProperties.currentHoverTarget = nil
        }
    }
    
    private func reorderPassObjects(draggedItem: PassObject, destinationItem: PassObject) {
        guard let fromIndex = modelData.passObjects.firstIndex(where: { $0.id == draggedItem.id }),
              let toIndex = modelData.passObjects.firstIndex(where: { $0.id == destinationItem.id }),
              fromIndex != toIndex else {
            return
        }
        
        print("Reordering: moving item from index \(fromIndex) to \(toIndex)")
        
        // Animate the reordering
        withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
            // Remove the dragged item from its current position
            let item = modelData.passObjects.remove(at: fromIndex)
            
            // Insert it at the new position
            modelData.passObjects.insert(item, at: toIndex)
        }
    }
}

#Preview {
    ContentView()
}
