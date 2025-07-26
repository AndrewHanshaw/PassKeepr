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
                                .draggable("asdf")
                                .aspectRatio(1 / 1.45, contentMode: .fill)
                                .background(Color.clear)
//                                .contextMenu {
//                                    let fileManager = FileManager.default
//                                    let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
//                                    let destinationURL = documentsDirectory.appendingPathComponent("\(passObject.id).pkpass")
//                                    ShareLink(item: destinationURL) {
//                                        Label("Share", systemImage: "square.and.arrow.up")
//                                    }
//
//                                    Button(action: {
//                                        let newPass = passObject.duplicate()
//                                        modelData.passObjects.append(newPass)
//                                        modelData.encodePassObjects()
//
//                                        if let pkpassDir = generatePass(passObject: newPass) {
//                                            Task {
//                                                passSigner.uploadPKPassFile(fileURL: pkpassDir, passUuid: newPass.id)
//                                            }
//                                            if passSigner.isDataLoaded == true {
//                                                passSigner.isDataLoaded = false
//                                            }
//                                        }
//                                    }) {
//                                        Label("Duplicate", systemImage: "rectangle.portrait.on.rectangle.portrait")
//                                    }
//
//                                    Button(role: .destructive, action: {
//                                        modelData.deleteItemByID(passObject.id)
//                                    }) {
//                                        Label("Delete", systemImage: "trash")
//                                    }
//                                }
                        }
                        /* preview: { _ in
                             Circle()
                                 .frame(width: 1, height: 1)
                                 .opacity(0)
                         } moveAction: { from, to in
                              modelData.passObjects.move(fromOffsets: from, toOffset: to)
                              modelData.encodePassObjects()
                          } */
                        .onMove { indices, newOffset in
                            modelData.passObjects.move(fromOffsets: indices, toOffset: newOffset)
                        }
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
        .overlay(alignment: .topLeading) {
            if let previewImage = dragProperties.previewImage, dragProperties.show {
                Image(uiImage: previewImage)
                    .opacity(0.8)
                    .offset(x: dragProperties.initialViewLocation.x, y: dragProperties.initialViewLocation.y)
                    .offset(dragProperties.offset)
                    .ignoresSafeArea()
            }
        }
        .environmentObject(dragProperties)
    }
}

struct PassCardContainer: View {
    @Binding var passObject: PassObject
    
    @EnvironmentObject private var properties: DragProperties
    @GestureState var isActive: Bool

    @State var shouldPresentEditPass = false

    var body: some View {
        GeometryReader { geometry in
            let rect = geometry.frame(in: .global)
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
//            preview: {
//                    PassCard(passObject: passObject)
//                        .opacity(0.8)
//                }
//                .gesture(
//                    DragGesture()
//                        .onChanged { value in
//                            print("DragGesture Start")
//                        }
//                        .onEnded { _ in
//                            print("DragGesture End")
//                        }
//                )
        }
        .onChange(of: isActive) { _, newValue in
            if newValue {
                print("isActive")
            } else {
                handleGestureEnd()
            }
        }
    }

    private func customGesture(rect: CGRect) -> some Gesture {
        LongPressGesture(minimumDuration: 0.3)
            .sequenced(before: DragGesture(coordinateSpace: .global))
            .updating($isActive, body: { _, out, _ in
                out = true
            })
            .onChanged { value in
                // This means that the long-press gesture has been finished successfully and drag gesture has been initiated
                if case let .second(_, gesture) = value {
                    handleGestureChange(gesture, rect: rect)
                }
            }
    }

    private func handleGestureChange(_ gesture: DragGesture.Value?, rect: CGRect) {
        if properties.previewImage == nil {
            properties.show = true
            properties.previewImage = createPreviewImage(rect: rect)
            properties.sourcePass = passObject
            properties.initialViewLocation = rect.origin
        }

        guard let gesture else { return }

        properties.offset = gesture.translation
        properties.location = gesture.location
    }

    private func createPreviewImage(rect: CGRect) -> UIImage? {
        let view = HStack {
            Text("asdf")
                .padding(.horizontal, 15)
                .foregroundStyle(.white)
                .frame(width: rect.width, height: rect.height, alignment: .leading)
                .background(.red)
        }

        let renderer = ImageRenderer(content: view)
        renderer.scale = UIScreen.main.scale

        return renderer.uiImage
    }

    private func handleGestureEnd() {
        withAnimation(.easeInOut(duration: 0.25), completionCriteria: .logicallyComplete) {
            properties.offset = .zero
        } completion: {
            properties.resetAllProperties()
        }
    }
}

#Preview {
    ContentView()
}
