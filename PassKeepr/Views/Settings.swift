//
//  Settings.swift
//  PassKeepr
//
//  Created by Andrew Hanshaw on 1/6/24.
//

import SwiftUI

struct Settings: View {
    let filename = "PassKeeprData.json"

    @Environment(ModelData.self) var modelData

    @State private var isDocumentPickerPresented: Bool = false

    var body: some View {
        Form(){
            Section {
                Button ("Delete All Passes", role: .destructive) {
                    modelData.deleteAllItems()
                }
                Button ("Delete Data File", role: .destructive) {
                    modelData.deleteDataFile()
                }
                let iconView = AppIcon().frame(width: 1024, height: 1024)
                let cgImage = ImageRenderer(content: iconView).cgImage!
                let uiimage = UIImage(cgImage: cgImage)
                Button ("Save Icon image") {
                    self.isDocumentPickerPresented.toggle()
                }
                .fileExporter(isPresented: $isDocumentPickerPresented, document: ImageDocument(image: uiimage), contentType: .image, defaultFilename: "iconImage.png") { result in
                    if case .success = result {
                        print("Image saved successfully.")
                    }
                }
            } footer: {Text("PassKeepr. Created by Drew Hanshaw")
            }
        }
    }
}

#Preview {
    Settings()
}
