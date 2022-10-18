//
//  ExpandedFilterSettingsView.swift
//  Scanner
//
//  Created by Nick Molargik on 10/11/22.
//

import SwiftUI

struct ExpandedFilterSettings: View {
    @ObservedObject var viewModel: MainViewModel
    @State private var refreshOnExit = false
    @State var dateFrom = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
    @State var dateTo = Date()
    @State var showingTypesPopover = false
    @State var selection = Set<Int>()
    @State var justAppeared1 = false
    @State var justAppeared2 = false
    @Environment(\.dismiss) var dismiss
    
    @AppStorage("useLocation") var useLocation = false
    @AppStorage("useDate") var useDate = false
    @AppStorage("radius") var radius = 2.0
    @AppStorage("showDistance") var showDistance = true
    
    let oldestDate = Calendar(identifier: .gregorian).date(from: DateComponents(year: 2018, month: 01, day: 01))!
    
    var body: some View {
        VStack {
            List (selection: $selection) {
                Section("Location") {
                    Text("This app only works for Fort Wayne, IN")
                    Toggle("Show Distance From You", isOn: $showDistance)
                    Toggle(isOn: $useLocation) {
                        Text("Filter By Distance")
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
                
                Section ("Filter By Activity") {
                    ForEach(viewModel.natures) { nature in
                        Text(nature.name.capitalized)
                            .lineLimit(1)
                            .minimumScaleFactor(0.75)
                    }
                    
                }
            }
        }
        .environment(\.editMode, .constant(EditMode.active))
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
        .onChange(of: dateFrom) {newValue in
            if (!justAppeared1) {
                refreshOnExit = true
            } else {
                justAppeared1 = false
            }
        }
        .onChange(of: dateTo) {newValue in
            if (!justAppeared2) {
                refreshOnExit = true
            } else {
                justAppeared2 = false
            }
        }
        .onDisappear {
            print("didDisappear")
            if dateFrom > dateTo {
                viewModel.dateFrom = dateTo
            } else {
                viewModel.dateFrom = dateFrom
            }
            viewModel.dateTo = dateTo
            if refreshOnExit {
                refreshOnExit = false
                viewModel.refresh()
            }
        }
        .onAppear {
            print("didAppear")
            refreshOnExit = false
            justAppeared1 = true
            justAppeared2 = true
            if !(Calendar.current.dateComponents([.day, .month, .year], from: dateFrom) == Calendar.current.dateComponents([.day, .month, .year], from: viewModel.dateFrom))
                || !(Calendar.current.dateComponents([.day, .month, .year], from: dateTo) == Calendar.current.dateComponents([.day, .month, .year], from: viewModel.dateTo)) {
                dateFrom = viewModel.dateFrom
                dateTo = viewModel.dateTo
            }
        }
    }
    
    func clearAllFilters() {
        withAnimation {
            useLocation = false
            useDate = false
            viewModel.selectedNatures.removeAll()
            dateFrom = Date()
            dateTo = Date()
        }
    }
}

struct ExpandedFilterSettings_Previews: PreviewProvider {
    static var previews: some View {
        ExpandedFilterSettings(viewModel: MainViewModel())
            .previewDevice(PreviewDevice(rawValue: "iPad Pro (11-inch) (3rd generation)"))
            .previewDisplayName("iPad Pro (11-inch) (3rd generation)")
    }
}
