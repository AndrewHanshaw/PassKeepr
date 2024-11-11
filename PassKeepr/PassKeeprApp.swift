//
//  PassKeeprApp.swift
//  PassKeepr
//
//  Created by Drew on 11/4/23.
//

import SwiftUI

@main
struct PassKeeprApp: App {
    @State private var modelData = ModelData()

    @StateObject var passSigner: pkPassSigner = .init()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(modelData)
                .environmentObject(passSigner)
        }
    }
}
