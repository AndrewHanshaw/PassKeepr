import SwiftUI

// Create a custom drag-and-drop effect instead of using the native drag-and-drop feature because it lacks customization options for its preview.Additionally, the observable object contains all of its associated data

class DragProperties: ObservableObject {
    // Drag Preview Properties
    @Published var show: Bool = false
    @Published var previewImage: UIImage?
    @Published var initialViewLocation: CGPoint = .zero
    @Published var updatedViewLocation: CGPoint = .zero
    
    @Published var draggedItem: PassObject?
    @Published var currentHoverTarget: PassObject?

    // Gesture Properties
    @Published var offset: CGSize = .zero
    @Published var location: CGPoint = .zero // For Grouping and Section Re-Ordering
    @Published var sourcePass: PassObject?
    @Published var destinationCategory: Category?
    @Published var isCardsSwapped: Bool = false

    func resetAllProperties() {
        show = false
        previewImage = nil
        initialViewLocation = .zero
        updatedViewLocation = .zero
        offset = .zero
        location = .zero
        sourcePass = nil
        destinationCategory = nil
        isCardsSwapped = false
    }
}
