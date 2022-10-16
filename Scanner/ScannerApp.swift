//
//  ScannerApp.swift
//  Scanner®
//
//  Created by Kyle Kincer on 1/11/22.
//

import SwiftUI
import Combine

@main
struct ScannerApp: App {
    @StateObject private var dataController = DataController()
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(\.managedObjectContext, dataController.container.viewContext)
        }
    }
}
