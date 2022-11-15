//
//  WatchSettingsView.swift
//  watchScanner Watch App
//
//  Created by Nick Molargik on 10/11/22.
//

import SwiftUI

struct WatchSettingsView: View {
    @ObservedObject var viewModel: MainViewModelWatch
    @State private var refreshOnExit = false
    
    @AppStorage("useLocation") var useLocation = false
    @AppStorage("radius") var radius = 2.0
    @AppStorage("showDistance") var showDistance = true
    
    let oldestDate = Calendar(identifier: .gregorian).date(from: DateComponents(year: 2018, month: 01, day: 01))!
    
    var body: some View {
        VStack {
            List {
                Section("This app only works for Fort Wayne, IN") {}
                Section("Sound and Vibration") {
                    Toggle("Enable Haptics and Sound", isOn: $viewModel.hapticsEnabled)
                }
            }
            .padding(.top)
        }
        .onChange(of: showDistance) { newValue in
            if !newValue {
                viewModel.clearDistancesFromActivities()
            }
            viewModel.refreshWatch()
        }
        .onDisappear {
            if refreshOnExit {
                refreshOnExit = false
                viewModel.refreshWatch()
            }
        }
        .onAppear {
            refreshOnExit = false
        }
    }
}

struct WatchSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        WatchSettingsView(viewModel: MainViewModelWatch())
    }
}
