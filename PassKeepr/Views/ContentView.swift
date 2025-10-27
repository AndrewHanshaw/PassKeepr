import SwiftUI

private let PADDING: CGFloat = 14

class DragProperties {
    var draggedID: UUID?
}

class DragState: ObservableObject {
    @Published var orderIDs: [UUID] = []
}

struct ContentView: View {
    @EnvironmentObject var modelData: ModelData
    @EnvironmentObject var passSigner: pkPassSigner

    @State private var plusButtonSize: CGSize = CGSizeZero

    @State var shouldPresentAddPass = false
    @State var shouldPresentSettings = false

    @StateObject private var dragState = DragState()
    @State private var dragProperties = DragProperties()

    @State private var lastDraggedID: UUID?
    @State private var lastDragEnded: Date?

    let columns: [GridItem] = Array(repeating: .init(.flexible(), spacing: PADDING), count: 2)

    var body: some View {
        NavigationView {
            ZStack {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: PADDING) {
                        ForEach(dragState.orderIDs, id: \.self) { id in
                            // Resolve a binding into the real model by ID
                            if let bindingIndex = modelData.passObjects.firstIndex(where: {
                                $0.id == id
                            }) {
                                PassCardContainer(passObject: $modelData.passObjects[bindingIndex])
                                    .aspectRatio(1 / 1.45, contentMode: .fill)
                                    .opacity(dragProperties.draggedID == id ? 0.001 : 1.0)
                                    .onDrag {
//                                      print("onDrag started for: \(passObject.id.uuidString)")

                                        // Check if this is a spurious drag call after a recent drop. Bug introduced in iOS 18 where onDrag is called an additional time after dropping the item
                                        if #available(iOS 18.0, *) {
                                            if let lastDropTime = lastDragEnded,
                                               lastDraggedID == id,
                                               Date().timeIntervalSince(lastDropTime) < 1.3
                                            {
//                                              print("Ignoring spurious drag call - too soon after last drop")
                                                return NSItemProvider()
                                            }
                                        }

                                        // Record this as the start of a legitimate drag
                                        dragProperties.draggedID = id
                                        lastDraggedID = id

                                        return NSItemProvider(object: NSString(string: id.uuidString))
                                    }
                                    .onDrop(
                                        of: [.text],
                                        delegate: PassDropDelegate(
                                            destinationID: id,
                                            dragState: dragState,
                                            dragProperties: dragProperties,
                                            onDropCompleted: {
                                                commitNewOrder()
                                                dragProperties.draggedID = nil
                                                lastDragEnded = Date()
                                            }
                                        )
                                    )
                            }
                        } // ForEach
                    }
                    .padding(PADDING)
                    .onAppear {
                        // initial order = current model order
                        dragState.orderIDs = modelData.passObjects.map(\.id)
                    }
                    .onChange(of: modelData.passObjects) {
                        // Keep orderIDs in sync when items are added/removed:
                        // remove missing ids, append newly added ids to the end
                        var ids = dragState.orderIDs
                        ids.removeAll { id in !modelData.passObjects.contains(where: { $0.id == id }) }
                        let existing = Set(ids)
                        let added = modelData.passObjects.map(\.id).filter { !existing.contains($0) }
                        ids.append(contentsOf: added)
                        dragState.orderIDs = ids
                    }
                }
                .scrollDisabled(modelData.passObjects.isEmpty)
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

    private func commitNewOrder() {
        // Reorder modelData.passObjects to follow dragState.orderIDs
        modelData.passObjects.sort { a, b in
            guard
                let ai = dragState.orderIDs.firstIndex(of: a.id),
                let bi = dragState.orderIDs.firstIndex(of: b.id)
            else { return false }
            return ai < bi
        }
        modelData.encodePassObjects()
    }
}

struct PassCardContainer: View {
    @Binding var passObject: PassObject
    @State private var shouldPresentEditPass = false

    var body: some View {
        PassCard(passObject: passObject)
            .onTapGesture {
                shouldPresentEditPass.toggle()
            }
            .sheet(isPresented: $shouldPresentEditPass) {
                EditPass(objectToEdit: $passObject)
                    .presentationDragIndicator(.visible)
            }
    }
}

struct PassDropDelegate: DropDelegate {
    let destinationID: UUID
    @ObservedObject var dragState: DragState
    let dragProperties: DragProperties
    let onDropCompleted: () -> Void

    func dropUpdated(info _: DropInfo) -> DropProposal? {
        DropProposal(operation: .move)
    }

    func performDrop(info _: DropInfo) -> Bool {
        onDropCompleted()
        return true
    }

    func dropEntered(info _: DropInfo) {
        guard let draggedID = dragProperties.draggedID,
              draggedID != destinationID,
              let fromIndex = dragState.orderIDs.firstIndex(of: draggedID),
              let toIndex = dragState.orderIDs.firstIndex(of: destinationID),
              fromIndex != toIndex
        else {
            return
        }

        // Animate the reordering
        withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
            dragState.orderIDs.move(
                fromOffsets: IndexSet(integer: fromIndex),
                toOffset: toIndex > fromIndex ? toIndex + 1 : toIndex
            )
        }
    }
}

#Preview {
    ContentView()
}
