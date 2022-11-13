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
                        Button {
                            showingTypesPopover = true
                        } label: {
                            Text(viewModel.selectedNatures.isEmpty ? "Filter By Natures" : "Types: (\(viewModel.selectedNatures.count))")
                        }
                    }
                }
            }
            .padding(.top, -15)
        }
        .popover(isPresented: $showingTypesPopover) {
            NaturesList(viewModel: viewModel)
        }
        .onAppear {
            refreshOnExit = false
            justAppeared1 = true
            justAppeared2 = true
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

struct FilterSettings_Previews: PreviewProvider {
    static var previews: some View {
        FilterSettings(viewModel: MainViewModel())
    }
}
