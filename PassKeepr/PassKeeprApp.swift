//
//  PassKeeprApp.swift
//  PassKeepr
//
//  Created by Drew on 11/4/23.
//

import SwiftUI

@main
struct PassKeeprApp: App {
    @StateObject var passSigner: pkPassSigner = .init()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(ModelData())
                .environmentObject(passSigner)
        }
    }
}
