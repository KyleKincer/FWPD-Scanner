//
//  ScannerTVApp.swift
//  ScannerTV
//
//  Created by Nick Molargik on 10/12/22.
//

import SwiftUI

@main
struct ScannerTVApp: App {
    var body: some Scene {
        WindowGroup {
            TVView()
                .edgesIgnoringSafeArea(.all)
        }
    }
}
