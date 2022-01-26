//
//  InitialTabView.swift
//  Scanner
//
//  Created by Kyle Kincer on 1/19/22.
//

import SwiftUI

struct InitialTabView: View {
    var body: some View {
        TabView {
            // List view
            let viewModel = ScannerActivityListViewModel()
            ScannerActivityListView(viewModel: viewModel)
                .tabItem {
                    Image(systemName: "list.dash")
                    Text("Activity")
                }
            MapView(listViewModel: viewModel)
                .tabItem {
                    Image(systemName: "map")
                    Text("Map")
                }
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
        }
    }
}

struct InitialTabView_Previews: PreviewProvider {
    static var previews: some View {
        InitialTabView()
    }
}
