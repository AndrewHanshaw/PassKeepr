import SwiftUI
import UIKit
import UniformTypeIdentifiers

class ShareViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        // Ensure access to extensionItem and itemProvider
        guard
            let extensionItem = extensionContext?.inputItems.first as? NSExtensionItem,
            let itemProvider = extensionItem.attachments?.first
        else {
            close()
            return
        }

        // Check type identifier - try multiple possible identifiers
        let possibleTypes = [
            "com.apple.pkpass",
            "com.apple.pkpass-data",
            "public.item",
            "public.data",
        ]

        var foundType: String?
        for typeId in possibleTypes {
            if itemProvider.hasItemConformingToTypeIdentifier(typeId) {
                foundType = typeId
                break
            }
        }

        guard let pkpassType = foundType else {
            close()
            return
        }

        if itemProvider.hasItemConformingToTypeIdentifier(pkpassType) {
            // Load the item from itemProvider
            itemProvider.loadItem(forTypeIdentifier: pkpassType, options: nil) {
                providedItem, error in
                if let error {
                    print("Error loading pkpass: \(error)")
                    self.close()
                    return
                }

                // Handle both URL (from Files app) and Data (from Wallet app)
                var finalURL: URL?

                if let url = providedItem as? URL {
                    finalURL = url
                } else if let data = providedItem as? Data {
                    // Save data to a temporary file
                    let tempDir = FileManager.default.temporaryDirectory
                    let tempFile = tempDir.appendingPathComponent("\(UUID().uuidString).pkpass")
                    do {
                        try data.write(to: tempFile)
                        finalURL = tempFile
                    } catch {
                        self.close()
                        return
                    }
                } else {
                    self.close()
                    return
                }

                guard let url = finalURL else {
                    self.close()
                    return
                }

                DispatchQueue.main.async {
                    // host the SwiftUI view
                    let contentView = UIHostingController(
                        rootView: ShareExtensionView(
                            pkpassURL: url, viewController: self
                        ))
                    self.addChild(contentView)
                    self.view.addSubview(contentView.view)

                    // set up constraints
                    contentView.view.translatesAutoresizingMaskIntoConstraints = false
                    contentView.view.topAnchor.constraint(equalTo: self.view.topAnchor)
                        .isActive = true
                    contentView.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
                        .isActive = true
                    contentView.view.leftAnchor.constraint(equalTo: self.view.leftAnchor)
                        .isActive = true
                    contentView.view.rightAnchor.constraint(equalTo: self.view.rightAnchor)
                        .isActive = true

                    // Set a clear background so the share sheet shows through
                    contentView.view.backgroundColor = .clear
                }
            }
        } else {
            close()
            return
        }
    }

    // Close the Share Extension
    func close() {
        extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
    }
}
