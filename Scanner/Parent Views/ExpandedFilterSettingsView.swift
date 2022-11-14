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
    @State var justAppeared1 = false
    @State var justAppeared2 = false
    @State var selection = Set<String>()
    @Environment(\.dismiss) var dismiss
    @Environment(\.editMode) private var editMode
    @AppStorage("selectedNatures") var selectedNatures = String()
    let oldestDate = Calendar(identifier: .gregorian).date(from: DateComponents(year: 2018, month: 01, day: 01))!
    
    var body: some View {
        VStack {
            List (selection: $selection) {
                Section("Location") {
                    Text("This app only works for Fort Wayne, IN")
                    
                    if (viewModel.locationEnabled) {
                        Toggle("Filter By Distance", isOn: $viewModel.useLocation)
                            .onChange(of: viewModel.useLocation) { _ in
                                refreshOnExit = true
                            }
                        
                        if (viewModel.useLocation) {
                            VStack {
                                HStack {
                                    Text("Radius: \(String(format: "%g", (round(viewModel.radius * 10)) / 10)) mi")
                                    Spacer()
                                }
                                Slider(value: $viewModel.radius, in: 0.1...5)
                                    .onChange(of: viewModel.radius) { _ in
                                        refreshOnExit = true
                                    }
                                
                                Section("Note: Traveling outside of Fort Wayne will prevent results from appearing when filtering by distance!") {}
                            }
                        }
                    }
                }
                
                Section("Date") {
                    Toggle("Filter By Date", isOn: $viewModel.useDate)
                        .onChange(of: viewModel.useDate) { _ in
                            refreshOnExit = true
                        }
                    
                    if (viewModel.useDate) {
                        DatePicker("From", selection: $dateFrom, in: oldestDate...dateTo, displayedComponents: .date)
                            .onChange(of: dateFrom) {newValue in
                                if (!justAppeared1) {
                                    refreshOnExit = true
                                } else {
                                    justAppeared1 = false
                                }
                            }
                        
                        
                        DatePicker("To", selection: $dateTo, in: oldestDate...Date(), displayedComponents: .date)
                            .onChange(of: dateTo) {newValue in
                                if (!justAppeared2) {
                                    refreshOnExit = true
                                } else {
                                    justAppeared2 = false
                                }
                            }
                    }
                }
                
                Section("Nature") {
                    Toggle("Filter By Natures", isOn: $viewModel.useNature)
                        .onChange(of: viewModel.useNature) { _ in
                            refreshOnExit = true
                        }
                    
                    if (viewModel.useNature) {
                        VStack {
                            Text("Select Natures")
                                .fontWeight(.semibold)
                                .italic()
                                .padding()
                            
                            List(selection: $selection, content: {
                                ForEach(viewModel.natures, id: \.name) { nature in
                                    Text(nature.name.capitalized)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.75)
                                }
                            })
                            .environment(\.editMode, .constant(EditMode.active))
                            .frame(height: 800)
                            .onAppear {
                                let selectionArray = selectedNatures.components(separatedBy: ", ")
                                selection = Set(selectionArray)
                                viewModel.selectedNatures = selection
                            }
                            .onChange(of: selection) { _ in
                                refreshOnExit = true
                            }
                        }
                    }
                }
            }
            .environment(\.editMode, .constant(EditMode.active))
            .onAppear {
                refreshOnExit = false
                justAppeared1 = true
                justAppeared2 = true
                viewModel.selectedNatures = selection
                viewModel.selectedNaturesString = Array(selection)
                selectedNatures = Array(selection).joined(separator: ", ")
            }
            .onDisappear {
                if dateFrom > dateTo {
                    viewModel.dateFrom = dateTo
                } else {
                    viewModel.dateFrom = dateFrom
                }
                viewModel.dateTo = dateTo
                if refreshOnExit {
                    refreshOnExit = false
                    viewModel.refresh()
                    print("Refreshed via Filters")
                }
                viewModel.selectedNaturesString = Array(viewModel.selectedNatures)
            }
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
