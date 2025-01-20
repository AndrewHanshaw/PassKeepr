import SwiftUI

public typealias Reorderable = Equatable & Identifiable

public extension View {
    func reorderableForEachContainer<Item: Reorderable>(
        active: Binding<Item?>
    ) -> some View {
        onDrop(of: [.text], delegate: ReorderableDropOutsideDelegate(active: active))
    }
}

public struct ReorderableForEach<Item: Reorderable, Content: View, Preview: View>: View {
    public init(
        _ items: Binding<[Item]>,
        active: Binding<Item?>,
        @ViewBuilder content: @escaping (Binding<Item>) -> Content,
        @ViewBuilder preview: @escaping (Item) -> Preview,
        moveAction: @escaping (IndexSet, Int) -> Void
    ) {
        _items = items
        _active = active
        self.content = content
        self.preview = preview
        self.moveAction = moveAction
    }

    public init(
        _ items: Binding<[Item]>,
        active: Binding<Item?>,
        @ViewBuilder content: @escaping (Binding<Item>) -> Content,
        moveAction: @escaping (IndexSet, Int) -> Void
    ) where Preview == EmptyView {
        _items = items
        _active = active
        self.content = content
        preview = nil
        self.moveAction = moveAction
    }

    @Binding
    private var active: Item?
    @Binding
    private var items: [Item]

    @State
    private var hasChangedLocation = false

    private let content: (Binding<Item>) -> Content
    private let preview: ((Item) -> Preview)?
    private let moveAction: (IndexSet, Int) -> Void

    public var body: some View {
        ForEach($items) { $item in
            if let preview {
                contentView(for: $item)
                    .onAppear {
                        print("pass \(item.id) appeared")
                    }
                    .onDrag {
                        dragData(for: $item)
                    } preview: {
                        preview(item)
                    }
            } else {
                contentView(for: $item)
                    .onDrag {
                        dragData(for: $item)
                    }
            }
        }
    }

    private func contentView(for item: Binding<Item>) -> some View {
        content(item)
            .zIndex(active == item.wrappedValue && hasChangedLocation ? .infinity : 0) // Always display dragged item on top
            .onDrop(
                of: [.text],
                delegate: ReorderableDragRelocateDelegate(
                    item: item.wrappedValue,
                    items: items,
                    active: $active,
                    hasChangedLocation: $hasChangedLocation
                ) { from, to in
                    withAnimation {
                        moveAction(from, to)
                    }
                }
            )
    }

    private func dragData(for item: Binding<Item>) -> NSItemProvider {
        active = item.wrappedValue
        return NSItemProvider(object: "\(item.wrappedValue.id)" as NSString)
    }
}

struct ReorderableDragRelocateDelegate<Item: Reorderable>: DropDelegate {
    let item: Item
    var items: [Item]

    @Binding var active: Item?
    @Binding var hasChangedLocation: Bool

    var moveAction: (IndexSet, Int) -> Void

    func dropEntered(info _: DropInfo) {
        guard item != active, let current = active else { return }
        guard let from = items.firstIndex(of: current) else { return }
        guard let to = items.firstIndex(of: item) else { return }
        hasChangedLocation = true
        if items[to] != current {
            moveAction(IndexSet(integer: from), to > from ? to + 1 : to)
        }
    }

    func dropUpdated(info _: DropInfo) -> DropProposal? {
        DropProposal(operation: .move)
    }

    func performDrop(info _: DropInfo) -> Bool {
        hasChangedLocation = false
        active = nil
        return true
    }
}

struct ReorderableDropOutsideDelegate<Item: Reorderable>: DropDelegate {
    @Binding
    var active: Item?

    func dropUpdated(info _: DropInfo) -> DropProposal? {
        DropProposal(operation: .move)
    }

    func performDrop(info _: DropInfo) -> Bool {
        active = nil
        return true
    }
}
