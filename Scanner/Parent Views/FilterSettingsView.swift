//
//  FilterPopover.swift
//  Scanner
//
//  Created by Kyle Kincer on 4/7/22.
//

import SwiftUI

struct FilterSettings: View {
    var viewModel: ScannerActivityListViewModel
    @State private var refreshOnExit = false
    @State var dateFrom = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
    @State var dateTo = Date()
    @State var showingTypesPopover = false
    
    @AppStorage("useLocation") var useLocation = false
    @AppStorage("useDate") var useDate = false
    @AppStorage("radius") var radius = 2.0
    @AppStorage("showDistance") var showDistance = true
    
    let oldestDate = Calendar(identifier: .gregorian).date(from: DateComponents(year: 2018, month: 01, day: 01))!
    
    var body: some View {
        VStack {
            Capsule()
                .fill(Color.secondary)
                .frame(width: 30, height: 3)
                .padding([.top, .leading, .trailing], 10)
            
            Text("Activity Filters")
                .fontWeight(.black)
                .italic()
                .font(.largeTitle)
                .shadow(radius: 2)
                .foregroundColor(Color("ModeOpposite"))
            
            List {
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
                
                Section("Date") {
                    Toggle(isOn: $useDate) {
                        Text("Filter By Date Range")
                    }
                    if useDate {
                        DatePicker("From", selection: $dateFrom, in: oldestDate...dateTo, displayedComponents: .date)
                        DatePicker("To", selection: $dateTo, in: oldestDate...Date(), displayedComponents: .date)
                    }
                }
                
                Section("Filter By Activity Type") {
                    Button {
                        showingTypesPopover = true
                    } label: {
                        Text(viewModel.selectedNatures.isEmpty ? "Select Activity Types" : "Types (\(viewModel.selectedNatures.count))")
                    }
                }
            }
            .padding(.top, -15)
        }
        .popover(isPresented: $showingTypesPopover) {
            NaturesList(viewModel: viewModel)
        }
        .onChange(of: useLocation) { _ in
                        refreshOnExit = true
        }
        .onChange(of: radius) { _ in
            if useLocation {
                refreshOnExit = true
            }
        }
        .onChange(of: showDistance) { newValue in
            if !newValue {
                viewModel.clearDistancesFromActivities()
            }
            viewModel.refresh()
        }
        .onChange(of: dateFrom) {newValue in
            refreshOnExit = true
        }
        .onChange(of: dateTo) {newValue in
            refreshOnExit = true
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

struct FilterSettings_Previews: PreviewProvider {
    static var previews: some View {
        FilterSettings(viewModel: ScannerActivityListViewModel())
    }
}
