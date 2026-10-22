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
            let wasAdded: Bool
            if let nonce = parent.pass.userInfo?[signNonceUserInfoKey] as? String {
                // containsPass only matches on pass type identifier + serial number, so it returns true
                // when an older version of this pass is already in Wallet. Compare the per-sign nonce instead.
                let walletPass = passLibrary.pass(withPassTypeIdentifier: parent.pass.passTypeIdentifier, serialNumber: parent.pass.serialNumber)
                wasAdded = (walletPass?.userInfo?[signNonceUserInfoKey] as? String) == nonce
            } else {
                wasAdded = passLibrary.containsPass(parent.pass) // fallback for passes without a nonce, use the standard containsPass check
            }

            // Call the callback with the result
            parent.onDismiss?(wasAdded)

            controller.dismiss(animated: true)
        }
    }
}
