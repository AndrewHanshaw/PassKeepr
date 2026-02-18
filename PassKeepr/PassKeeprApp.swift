import SwiftUI

@main
struct PassKeeprApp: App {
    @StateObject var passSigner: pkPassSigner = .init()
    @StateObject var modelData = ModelData()
    @State private var importedPassURL: URL?
    @Environment(\.scenePhase) var scenePhase

    var body: some Scene {
        WindowGroup {
            ContentView(importedPassURL: $importedPassURL)
                .environmentObject(modelData)
                .environmentObject(passSigner)
                .onOpenURL { url in
                    handleIncomingURL(url)
                }
                .onChange(of: scenePhase) { _, newPhase in
                    if newPhase == .active {
                        checkForPendingImport()
                    }
                }
                .onAppear {
                    checkForPendingImport()
                }
        }
    }

    private func checkForPendingImport() {
        guard
            let sharedURL = FileManager.default.containerURL(
                forSecurityApplicationGroupIdentifier: "group.com.hanshaw.passKeepr")
        else {
            return
        }

        let flagFile = sharedURL.appendingPathComponent("pending_import.txt")

        // Check if there's a pending import
        if FileManager.default.fileExists(atPath: flagFile.path),
           let fileName = try? String(contentsOf: flagFile, encoding: .utf8)
        {
            print("Found pending import: \(fileName)")

            let fileURL = sharedURL.appendingPathComponent(fileName)
            if FileManager.default.fileExists(atPath: fileURL.path) {
                importedPassURL = fileURL
            }

            // Clean up the flag file
            try? FileManager.default.removeItem(at: flagFile)
        }
    }

    private func handleIncomingURL(_ url: URL) {
        guard url.scheme == "passkeepr" else { return }

        if url.host == "import" {
            // Extract the filename from the query parameter
            if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
               let fileQueryItem = components.queryItems?.first(where: { $0.name == "file" }),
               let fileName = fileQueryItem.value
            {
                // Get the file from the shared container
                let sharedContainerURL = FileManager.default.containerURL(
                    forSecurityApplicationGroupIdentifier: "group.com.hanshaw.passKeepr")

                if let sharedURL = sharedContainerURL {
                    let fileURL = sharedURL.appendingPathComponent(fileName)
                    importedPassURL = fileURL

                    // Clean up the flag file since we're handling it via URL scheme
                    let flagFile = sharedURL.appendingPathComponent("pending_import.txt")
                    try? FileManager.default.removeItem(at: flagFile)
                }
            }
        }
    }
}
