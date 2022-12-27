//
//  ExpandedFilterSettingsView.swift
//  Scanner
//
//  Created by Nick Molargik on 10/11/22.
//

import SwiftUI

struct FilterSettingsView: View {
    @Binding var showFilter: Bool
    @ObservedObject var viewModel: MainViewModel
    @State private var refreshOnExit = false
    @State var showingTypesPopover = false
    @State var justAppeared1 = false
    @State var justAppeared2 = false
    @State var selection = Set<String>()
    @State var dateFrom = Date()
    @State var dateTo = Date()
    @State var tenSet = Set<String>()
    @State var showNatureAlert = false
    @State private var searchText = ""
    @State var showPage : Bool = false
    @State var signingUp : Bool = false
    @Environment(\.dismiss) var dismiss
    @Environment(\.editMode) private var editMode

    let oldestDate = Calendar(identifier: .gregorian).date(from: DateComponents(year: 2018, month: 01, day: 01))!
    
    var body: some View {
        VStack {
            
            Button(action: {
                withAnimation {
                    showFilter.toggle()
                }
            }, label: {
                BackButtonView(text: "Apply", color: .green)
            })
            
            Text("Activity Filters")
                .fontWeight(.black)
                .italic()
                .font(.largeTitle)
                .shadow(radius: 2)
                .foregroundColor(Color("ModeOpposite"))
                .padding(.top)
            
            Text("Only one Scanner Filter Category may be applied at a time.")
                .multilineTextAlignment(.center)
                .font(.subheadline)
            
            Text("This app only works for Fort Wayne, IN")
                .multilineTextAlignment(.center)
                .font(.subheadline)
            
            VStack {                
                if (viewModel.locationEnabled) {
                    Toggle("Filter By Distance", isOn: $viewModel.useLocation)
                        .onChange(of: viewModel.useLocation) { newValue in
                            refreshOnExit = true
                            
                            if (newValue) {
                                viewModel.useDate = false
                                viewModel.useNature = false
                            }
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
                    
                    Divider()
                }
                
                Toggle("Filter By Date", isOn: $viewModel.useDate)
                    .onChange(of: viewModel.useDate) { newValue in
                        refreshOnExit = true
                        
                        if (newValue) {
                            withAnimation {
                                viewModel.useLocation = false
                                viewModel.useNature = false
                            }
                        }
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
                
                Divider()
                
                
                Toggle("Filter By Natures", isOn: $viewModel.useNature)
                    .onChange(of: viewModel.useNature) { newValue in
                        refreshOnExit = true
                        
                        withAnimation {
                            if (newValue) {
                                viewModel.useDate = false
                                viewModel.useLocation = false
                            }
                        }
                    }
                
                if (viewModel.useNature) {
                    HStack {
                        Text("Select Natures")
                            .padding(.leading, -18)
                        
                        Spacer()
                        
                        Button {
                            selection.removeAll()
                        } label: {
                            Text("Clear")
                        }
                        .disabled(selection.count == 0 || selection.first == "")
                    }
                    .padding()
                    
                    TextField("Search", text: $searchText)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal)
                    
                    List(selection: $selection, content: {
                        ForEach(searchResults, id: \.name) { nature in
                            Text(nature.name.capitalized)
                                .lineLimit(1)
                                .minimumScaleFactor(0.75)
                        }
                    })
                    .environment(\.editMode, .constant(EditMode.active))
                    .onAppear {
                        let selectionArray = viewModel.selectedNaturesUD.components(separatedBy: ", ")
                        selection = Set(selectionArray)
                        viewModel.selectedNatures = selection
                    }
                    .onChange(of: selection, perform: { latestSelection in
                        if (latestSelection.count == 10) {
                            tenSet = latestSelection
                        }
                        if (latestSelection.count >= 11) {
                            showNatureAlert = true
                            selection = tenSet
                        }
                        
                    })
                }
                
                Spacer()
            }
            .padding(.horizontal, 30)
            .padding(.vertical, 10)
        }

        .environment(\.editMode, .constant(EditMode.active))
        .onAppear {
            if (viewModel.selectedNatures.count == 1) {
                viewModel.selectedNatures.insert("None")
            }
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd 00:00:01"
            dateFrom = formatter.date(from: viewModel.dateFrom) ?? Date()
            formatter.dateFormat = "yyyy-MM-dd 23:59:59"
            dateTo = formatter.date(from: viewModel.dateTo) ?? Date()
            justAppeared1 = true
            justAppeared2 = true
            let selectionArray = viewModel.selectedNaturesUD.components(separatedBy: ", ")
            selection = Set(selectionArray)
            viewModel.selectedNatures = selection
            refreshOnExit = false
            
        }
        .onDisappear {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd 00:00:01"
            viewModel.dateFrom = formatter.string(from: dateFrom)
            formatter.dateFormat = "yyyy-MM-dd 23:59:59"
            viewModel.dateTo = formatter.string(from: dateTo)
            
            if (selection.count == 0) {
                viewModel.useNature = false
                selection.insert("None")
            }
            
            viewModel.selectedNatures = selection
            viewModel.selectedNaturesString = Array(selection)
            viewModel.selectedNaturesUD = Array(selection).joined(separator: ", ")
            
            if refreshOnExit {
                refreshOnExit = false
                viewModel.refresh()
                print("R - Refreshed via Filters")
                viewModel.showMostRecentComments = false
            }
        }
        .alert("We currently limit nature selection to 10 natures. Please deselect some natures to add new ones.", isPresented: $showNatureAlert) {
            Button("OK", role: .cancel) { }
        }
    }
    
    @MainActor
    var searchResults: [Scanner.Nature] {
        if searchText.isEmpty {
            return viewModel.natures
        } else {
            return viewModel.natures.filter { $0.name.contains(searchText.uppercased()) }
        }
    }
}

struct FilterSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        FilterSettingsView(showFilter: .constant(true), viewModel: MainViewModel())
            .previewDevice(PreviewDevice(rawValue: "iPad Pro (11-inch) (3rd generation)"))
            .previewDisplayName("iPad Pro (11-inch) (3rd generation)")
    }
}
