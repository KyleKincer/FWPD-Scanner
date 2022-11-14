//
//  WatchSettingsView.swift
//  watchScanner Watch App
//
//  Created by Nick Molargik on 10/11/22.
//

import SwiftUI

struct WatchSettingsView: View {
    @ObservedObject var viewModel: MainViewModel
    @State private var refreshOnExit = false
    
    @AppStorage("useLocation") var useLocation = false
    @AppStorage("radius") var radius = 2.0
    @AppStorage("showDistance") var showDistance = true
    
    let oldestDate = Calendar(identifier: .gregorian).date(from: DateComponents(year: 2018, month: 01, day: 01))!
    
    var body: some View {
        VStack {
            List {
                Section("Activity Filters") {
                    Text("This app only works for Fort Wayne, IN")
                    Toggle("Show Distance From You", isOn: $showDistance)
                    Toggle(isOn: $useLocation) {
                        Text("Filter By Distance")
                            .onTapGesture {
                                viewModel.refresh()
                            }
                    }
                    if useLocation {
                        VStack {
                            HStack {
                                Text("Radius: \(String(format: "%g", (round(radius * 10)) / 10)) mi")
                                Spacer()
                            }
                            Slider(value: $radius, in: 0.1...5)
                        }
                    }
                }
            }
            .padding(.top, -15)
        }
        .onChange(of: useLocation) { _ in
            refreshOnExit = true
        }
        .onChange(of: radius) { _ in
            if useLocation {
                refreshOnExit = true
            }
            viewModel.refresh()
        }
        .onChange(of: showDistance) { newValue in
            if !newValue {
                viewModel.clearDistancesFromActivities()
            }
            viewModel.refresh()
        }
        .onDisappear {
            if refreshOnExit {
                refreshOnExit = false
                viewModel.refresh()
            }
        }
        .onAppear {
            refreshOnExit = false
        }
    }
}

struct WatchSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        WatchSettingsView(viewModel: MainViewModel())
    }
}
