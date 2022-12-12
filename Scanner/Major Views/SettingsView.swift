//
//  SettingsView.swift
//  Scanner
//
//  Created by Kyle Kincer on 4/7/22.
//

import SwiftUI

struct SettingsView: View {
    @Binding var showFilter: Bool
    @ObservedObject var viewModel: MainViewModel   
    @State var refreshOnExit = false
    @State var showingTypesPopover = false
    @State var justAppeared1 = false
    @State var justAppeared2 = false
    @State var dateFrom = Date()
    @State var dateTo = Date()
    let oldestDate = Calendar(identifier: .gregorian).date(from: DateComponents(year: 2018, month: 01, day: 01))!
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    withAnimation {
                        showFilter.toggle()
                    }
                }, label: {
                    HStack {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 30))
                        
                        Text("Back")
                    }
                })
                .padding([.leading, .top])
                .foregroundColor(.green)
                
                Spacer()
                
            }
            .padding(.horizontal)
            
            Text("Settings")
                .fontWeight(.black)
                .italic()
                .font(.largeTitle)
                .shadow(radius: 2)
                .foregroundColor(Color("ModeOpposite"))
            
            Text("Only one Scanner Filter Category may be applied.")
                .multilineTextAlignment(.center)
                .font(.subheadline)
                .padding()
            
            List {
                Section("Location") {
                    Text("This app only works for Fort Wayne, IN")
                        .multilineTextAlignment(.center)
                    
                    if (viewModel.location.locationEnabled) {
                        Toggle("Filter By Distance", isOn: $viewModel.filters.useLocation)
                            .onChange(of: viewModel.filters.useLocation) { newValue in
                                withAnimation {
                                    refreshOnExit = true
                                    if (newValue) {
                                        viewModel.filters.useDate = false
                                        viewModel.filters.useNature = false
                                    }
                                }
                            }
                        
                        if (viewModel.filters.useLocation) {
                            VStack {
                                HStack {
                                    Text("Radius: \(String(format: "%g", (round(viewModel.filters.radius * 10)) / 10)) mi")
                                    Spacer()
                                }
                                Slider(value: $viewModel.filters.radius, in: 0.1...5)
                                    .onChange(of: viewModel.filters.radius) { _ in
                                        refreshOnExit = true
                                    }
                                
                                Section("Note: Traveling outside of Fort Wayne will prevent results from appearing when filtering by distance!") {}
                            }
                        }
                    }
                }
                
                Section("Date") {
                    Toggle("Filter By Date", isOn: $viewModel.filters.useDate)
                        .onChange(of: viewModel.filters.useDate) { newValue in
                            refreshOnExit = true
                            if (newValue) {
                                withAnimation {
                                    viewModel.filters.useLocation = false
                                    viewModel.filters.useNature = false
                                }
                            }
                        }
                    
                    if (viewModel.filters.useDate) {
                        DatePicker("From", selection: $dateFrom, in: oldestDate...dateTo, displayedComponents: .date)
                            .onChange(of: dateFrom) { newValue in
                                withAnimation {
                                    if (!justAppeared1) {
                                        refreshOnExit = true
                                    } else {
                                        justAppeared1 = false
                                    }
                                }
                            }
                        
                        
                        DatePicker("To", selection: $dateTo, in: oldestDate...Date(), displayedComponents: .date)
                            .onChange(of: dateTo) { newValue in
                                if (!justAppeared2) {
                                    refreshOnExit = true
                                } else {
                                    justAppeared2 = false
                                }
                            }
                    }
                }
                
                Section("Nature") {
                    Toggle("Filter By Natures", isOn: $viewModel.filters.useNature)
                        .onChange(of: viewModel.filters.useNature) { newValue in
                            refreshOnExit = true
                            withAnimation {
                                if (newValue) {
                                    viewModel.filters.useDate = false
                                    viewModel.filters.useLocation = false
                                }
                            }
                        }
                    
                    if (viewModel.filters.useNature) {
                        Button {
                            withAnimation {
                                showingTypesPopover = true
                            }
                        } label: {
                            Text(viewModel.filters.selectedNatures.isEmpty ? "Filter By Natures" : "Types: \(viewModel.filters.selectedNatures.count - 1)")
                        }
                    }
                }
            }
            .padding(.top, -15)
        }
        .popover(isPresented: $showingTypesPopover) {
            NaturesList(viewModel: viewModel)
                .onDisappear {
                    refreshOnExit = true
                }
        }
        .onAppear {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd 00:00:01"
            dateFrom = formatter.date(from: viewModel.filters.dateFrom) ?? Date()
            formatter.dateFormat = "yyyy-MM-dd 23:59:59"
            dateTo = formatter.date(from: viewModel.filters.dateTo) ?? Date()
            refreshOnExit = false
            justAppeared1 = true
            justAppeared2 = true
            if (viewModel.filters.selectedNatures.count == 1) {
                viewModel.filters.selectedNatures.insert("None")
            }
        }
        .onDisappear {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd 00:00:01"
            viewModel.filters.dateFrom = formatter.string(from: dateFrom)
            formatter.dateFormat = "yyyy-MM-dd 23:59:59"
            viewModel.filters.dateTo = formatter.string(from: dateTo)

            if refreshOnExit {
                refreshOnExit = false
                viewModel.refresh()
                print("R - Refreshed via Filters")
            }
        }
    }
}

struct FilterSettings_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(showFilter: .constant(true), viewModel: MainViewModel())
    }
}
