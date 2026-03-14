import SwiftUI
import UIKit

extension UIView {
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = next
        while parentResponder != nil {
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
            parentResponder = parentResponder?.next
        }
        return nil
    }
}

final class SheetDelegate: NSObject, UIAdaptivePresentationControllerDelegate {
    var isDisabled: Bool
    @Binding var attemptToDismiss: UUID

    init(_ isDisabled: Bool, attemptToDismiss: Binding<UUID> = .constant(UUID())) {
        self.isDisabled = isDisabled
        _attemptToDismiss = attemptToDismiss
    }

    func presentationControllerShouldDismiss(_: UIPresentationController) -> Bool {
        !isDisabled
    }

    func presentationControllerDidAttemptToDismiss(_: UIPresentationController) {
        attemptToDismiss = UUID()
    }
}

struct SetSheetDelegate: UIViewRepresentable {
    let delegate: SheetDelegate

    init(isDisabled: Bool, attemptToDismiss: Binding<UUID>) {
        delegate = SheetDelegate(isDisabled, attemptToDismiss: attemptToDismiss)
    }

    func makeUIView(context _: Context) -> some UIView {
        let view = UIView()
        return view
    }

    func updateUIView(_ uiView: UIViewType, context _: Context) {
        DispatchQueue.main.async {
            uiView.parentViewController?.presentationController?.delegate = delegate
        }
    }
}

extension View {
    func interactiveDismissDisabled(_ isDisabled: Bool, attemptToDismiss: Binding<UUID>) -> some View {
        background(SetSheetDelegate(isDisabled: isDisabled, attemptToDismiss: attemptToDismiss))
    }
}
