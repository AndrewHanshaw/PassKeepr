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
                print("onDrag started")
                return NSItemProvider(object: NSString(string: passObject.id.uuidString))
            }
    }
}

#Preview {
    ContentView()
}
