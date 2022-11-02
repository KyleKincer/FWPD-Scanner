//
//  FilterPopover.swift
//  Scanner
//
//  Created by Kyle Kincer on 4/7/22.
//

import SwiftUI

struct FilterSettings: View {
    @ObservedObject var viewModel: MainViewModel   
    @State var refreshOnExit = false
    @State var dateFrom = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
    @State var dateTo = Date()
    @State var showingTypesPopover = false
    @State var justAppeared1 = false
    @State var justAppeared2 = false
    @State var showFavorites = false
    
    @AppStorage("useLocation") var useLocation = false
    @AppStorage("useDate") var useDate = false
    @AppStorage("radius") var radius = 0.0
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
                        .multilineTextAlignment(.center)
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
                
                if (useLocation) {
                    Section("Note: Traveling outside of Fort Wayne will prevent results from appearing when filteirng by distance!") {
                        
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
                    Text("Bookmarks Saved: \(viewModel.bookmarkCount)")
                    Toggle(isOn: $viewModel.showBookmarks) {
                        Text("Only Show Bookmarks")

                    }.onTapGesture {
                        if (viewModel.showBookmarks) {
                            viewModel.showBookmarks = false
                            viewModel.refresh()
                            
                        } else {
                            viewModel.getBookmarks()
                        }
                    }.disabled(viewModel.bookmarkCount == 0)
                    
                    Button {
                        showingTypesPopover = true
                    } label: {
                        Text(viewModel.selectedNatures.isEmpty ? "Filter By Activity Types" : "Types: (\(viewModel.selectedNatures.count))")
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
            if dateFrom > dateTo {
                viewModel.dateFrom = dateTo
            } else {
                viewModel.dateFrom = dateFrom
            }
            viewModel.dateTo = dateTo
            if refreshOnExit {
                refreshOnExit = false
                viewModel.refresh()
                print("Refreshed")
            }
        }
        .onAppear {
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

struct FilterSettings_Previews: PreviewProvider {
    static var previews: some View {
        FilterSettings(viewModel: MainViewModel())
    }
}
