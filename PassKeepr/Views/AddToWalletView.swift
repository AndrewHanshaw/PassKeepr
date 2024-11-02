import PassKit
import SwiftUI

struct AddToWalletView: UIViewControllerRepresentable {
    var pass: PKPass

    // Add a callback closure to handle the result
    var onDismiss: ((Bool) -> Void)?

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> PKAddPassesViewController {
        let passvc = PKAddPassesViewController(pass: pass)
        passvc?.delegate = context.coordinator
        return passvc!
    }

    func updateUIViewController(_: PKAddPassesViewController, context _: Context) {}

    // Coordinator class to handle the delegate
    class Coordinator: NSObject, PKAddPassesViewControllerDelegate {
        var parent: AddToWalletView

        init(_ parent: AddToWalletView) {
            self.parent = parent
        }

        func addPassesViewControllerDidFinish(_ controller: PKAddPassesViewController) {
            // Check if the pass was added
            let passLibrary = PKPassLibrary()
            let wasAdded = passLibrary.containsPass(parent.pass)

            // Call the callback with the result
            parent.onDismiss?(wasAdded)

            controller.dismiss(animated: true)
        }
    }
}
