import SwiftUI

struct ShareExtensionView: View {
    let pkpassURL: URL
    weak var viewController: UIViewController?

    var extensionContext: NSExtensionContext? {
        viewController?.extensionContext
    }

    var body: some View {
        // Immediately trigger the import and close - no UI needed
        Color.clear
            .onAppear {
                openInMainApp()
            }
    }

    private func openInMainApp() {
        // Copy the file to a shared container that both the extension and main app can access
        let sharedContainerURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: "group.com.hanshaw.passKeepr")

        guard let sharedURL = sharedContainerURL else {
            print("Failed to get shared container URL")
            close()
            return
        }

        // Create a temporary file in the shared container
        let tempFileName = "\(UUID().uuidString).pkpass"
        let destinationURL = sharedURL.appendingPathComponent(tempFileName)

        do {
            // Copy the pkpass file to the shared container
            if FileManager.default.fileExists(atPath: destinationURL.path) {
                try FileManager.default.removeItem(at: destinationURL)
            }
            try FileManager.default.copyItem(at: pkpassURL, to: destinationURL)

            print("Copied file to: \(destinationURL.path)")

            // Write a flag file to signal the main app
            let flagFile = sharedURL.appendingPathComponent("pending_import.txt")
            try? tempFileName.write(to: flagFile, atomically: true, encoding: .utf8)

            // Try to open the main app with URL scheme (works on device, may fail on simulator)
            guard
                let encodedFileName = tempFileName.addingPercentEncoding(
                    withAllowedCharacters: .urlQueryAllowed),
                let url = URL(string: "passkeepr://import?file=\(encodedFileName)")
            else {
                print("Failed to create URL, but file is ready for import")
                close()
                return
            }

            print("Opening URL: \(url.absoluteString)")

            // Use the responder chain method to open the URL - start from the view controller
            var responder: UIResponder? = viewController

            while responder != nil {
                if let application = responder as? UIApplication {
                    if #available(iOS 18.0, *) {
                        application.open(url, options: [:]) { success in
                            print("UIApplication.open result: \(success)")
                        }
                    } else {
                        let selector = sel_registerName("openURL:")
                        _ = application.perform(selector, with: url)
                        print("Called openURL via perform selector")
                    }

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        self.close()
                    }
                    return
                }
                responder = responder?.next
            }

            print("Could not find UIApplication in responder chain")
            close()
        } catch {
            print("Error copying file: \(error)")
            close()
        }
    }

    private func close() {
        extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
    }
}
