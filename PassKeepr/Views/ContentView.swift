import SwiftUI

private let PADDING: CGFloat = 14

class DragProperties: ObservableObject {
    @Published var draggedItem: PassObject?
    @Published var currentHoverTarget: PassObject?
}

struct ContentView: View {
    @EnvironmentObject var modelData: ModelData
    @EnvironmentObject var passSigner: pkPassSigner

    @State private var plusButtonSize: CGSize = CGSizeZero

    @State var shouldPresentAddPass = false
    @State var shouldPresentSettings = false

    @State private var active: PassObject?

    @StateObject private var dragProperties: DragProperties = .init()
    @State var lastDraggedItem: PassObject?
    @State var lastDragEnded: Date?

    let columns: [GridItem] = Array(repeating: .init(.flexible(), spacing: PADDING), count: 2)

    var body: some View {
        NavigationView {
            ZStack {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: PADDING) {
                        ForEach($modelData.passObjects) { $passObject in
                            PassCardContainer(passObject: $passObject)
                                .aspectRatio(1 / 1.45, contentMode: .fill)
                                .background(Color.clear)
                                .scaleEffect(dragProperties.currentHoverTarget?.id == passObject.id ? 1.02 : 1.0)
                                .onDrag {
//                                    print("onDrag started for: \(passObject.id.uuidString)")

                                    // Check if this is a spurious drag call after a recent drop. Bug introduced in iOS 18 where onDrag is called an additional time after dropping the item
                                    if #available(iOS 18.0, *) {
                                        if let lastDropTime = lastDragEnded,
                                           lastDraggedItem?.id == passObject.id,
                                           Date().timeIntervalSince(lastDropTime) < 1.3
                                        {
//                                            print("Ignoring spurious drag call - too soon after last drop")
                                            return NSItemProvider()
                                        }
                                    }

                                    // Record this as the start of a legitimate drag
                                    lastDraggedItem = passObject
                                    dragProperties.draggedItem = passObject

                                    return NSItemProvider(object: NSString(string: passObject.id.uuidString))
                                } preview: {
                                    Circle()
                                        .frame(width: 1, height: 1)
                                        .opacity(0)
                                }
                                .onDrop(of: [.text], delegate: PassDropDelegate(
                                    destinationItem: passObject,
                                    modelData: modelData,
                                    dragProperties: dragProperties,
                                    onDropCompleted: {
//                                        print("Drop Completed")
                                        lastDragEnded = Date() // Update the timeout tracking when drop completes
                                    }
                                ))
                        }
                    }
                    .padding(PADDING)
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
        .environmentObject(dragProperties)
    }
}

struct PassCardContainer: View {
    @Binding var passObject: PassObject

    @EnvironmentObject var modelData: ModelData

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
    }
}

struct PassDropDelegate: DropDelegate {
    let destinationItem: PassObject
    let modelData: ModelData
    let dragProperties: DragProperties
    let onDropCompleted: () -> Void

    func dropUpdated(info _: DropInfo) -> DropProposal? {
        DropProposal(operation: .move)
    }

    func performDrop(info _: DropInfo) -> Bool {
        // Clean up drag state and save the final order
        defer {
            dragProperties.draggedItem = nil
            dragProperties.currentHoverTarget = nil

            // Notify that drop completed for timeout tracking
            onDropCompleted()

            // Save the final reordered state
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                modelData.encodePassObjects()
            }
        }

        // The array is already in the correct order from the live reordering so we just need to confirm the drop was successful
        return true
    }

    func dropEntered(info _: DropInfo) {
        guard let draggedItem = dragProperties.draggedItem,
              draggedItem.id != destinationItem.id
        else {
            return
        }

        // Update hover target for visual feedback
        dragProperties.currentHoverTarget = destinationItem

        // Perform real-time reordering of the actual array
        reorderPassObjects(draggedItem: draggedItem, destinationItem: destinationItem)
    }

    func dropExited(info _: DropInfo) {
        // Clear hover target when exiting
        if dragProperties.currentHoverTarget?.id == destinationItem.id {
            dragProperties.currentHoverTarget = nil
        }
    }

    private func reorderPassObjects(draggedItem: PassObject, destinationItem: PassObject) {
        guard let fromIndex = modelData.passObjects.firstIndex(where: { $0.id == draggedItem.id }),
              let toIndex = modelData.passObjects.firstIndex(where: { $0.id == destinationItem.id }),
              fromIndex != toIndex
        else {
            return
        }

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
