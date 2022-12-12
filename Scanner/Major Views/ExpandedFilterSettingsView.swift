//
//  ExpandedFilterSettingsView.swift
//  Scanner
//
//  Created by Nick Molargik on 10/11/22.
//

import SwiftUI

struct ExpandedFilterSettings: View {
    @Binding var showFilter: Bool
    @ObservedObject var viewModel: MainViewModel
    @State private var refreshOnExit = false
    @State var showingTypesPopover = false
    @State var justAppeared1 = false
    @State var justAppeared2 = false
    @State var selection = Set<String>()
    @State var dateFrom = Date()
    @State var dateTo = Date()
    @Environment(\.dismiss) var dismiss
    @Environment(\.editMode) private var editMode
    @State var tenSet = Set<String>()
    @State var showNatureAlert = false
    @State private var searchText = ""
    @State var showPage : Bool = false
    @State var signingUp : Bool = false
    let oldestDate = Calendar(identifier: .gregorian).date(from: DateComponents(year: 2018, month: 01, day: 01))!
    
    var body: some View {
        VStack {
            
            ZStack {
                Text("Activity Filters")
                    .fontWeight(.black)
                    .italic()
                    .font(.largeTitle)
                    .shadow(radius: 2)
                    .foregroundColor(Color("ModeOpposite"))
                    .padding(.top)
                
                HStack {
                    Button(action: {
                        if (selection.count-1 == 0) {
                            viewModel.filters.useNature = false
                            selection.insert("None")
                        }
                        dismiss()
                    }, label: {
                        HStack {
                            Image(systemName: "arrow.left")
                                .font(.system(size: 30))
                            Text("Save Filters")
                                .padding([.trailing, .vertical])
                        }
                    })
                    .padding(.leading)
                    .foregroundColor(.green)
                    
                    Spacer()
                    
                }
            }
            
            Text("Only one Scanner Filter Category may be applied at a time.")
                .multilineTextAlignment(.center)
                .font(.subheadline)
            
            Text("This app only works for Fort Wayne, IN")
                .multilineTextAlignment(.center)
                .font(.subheadline)
            
            
            VStack {
                Section("Account") {
                    if viewModel.auth.loggedIn {
                        Text("Howdy, \(viewModel.auth.username)!")
                    }
                    Button {
                        if !viewModel.auth.loggedIn {
                            showPage = true
                        } else {
                            viewModel.auth.logOut()
                        }
                    } label: {
                        Text(viewModel.auth.loggedIn ? "Log out" : "Log in")
                    }
                }
                
                if (viewModel.location.locationEnabled) {
                    Toggle("Filter By Distance", isOn: $viewModel.filters.useLocation)
                        .onChange(of: viewModel.filters.useLocation) { newValue in
                            refreshOnExit = true
                            
                            if (newValue) {
                                viewModel.filters.useDate = false
                                viewModel.filters.useNature = false
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
                    
                    Divider()
                }
                
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
                        let selectionArray = viewModel.filters.selectedNaturesUD.components(separatedBy: ", ")
                        selection = Set(selectionArray)
                        viewModel.filters.selectedNatures = selection
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
            .padding(.horizontal, 70)
            .padding(.vertical, 10)
        }
        .fullScreenCover(isPresented: $showPage, content: {
            if (signingUp) {
                RegisterView(viewModel: viewModel, signingUp: $signingUp, showPage: $showPage)
            } else {
                LoginView(viewModel: viewModel, signingUp: $signingUp, showPage: $showPage)
            }
        })
        .environment(\.editMode, .constant(EditMode.active))
        .onAppear {
            if (viewModel.filters.selectedNatures.count == 1) {
                viewModel.filters.selectedNatures.insert("None")
            }
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd 00:00:01"
            dateFrom = formatter.date(from: viewModel.filters.dateFrom) ?? Date()
            formatter.dateFormat = "yyyy-MM-dd 23:59:59"
            dateTo = formatter.date(from: viewModel.filters.dateTo) ?? Date()
            justAppeared1 = true
            justAppeared2 = true
            let selectionArray = viewModel.filters.selectedNaturesUD.components(separatedBy: ", ")
            selection = Set(selectionArray)
            viewModel.filters.selectedNatures = selection
            refreshOnExit = false
            
        }
        .onDisappear {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd 00:00:01"
            viewModel.filters.dateFrom = formatter.string(from: dateFrom)
            formatter.dateFormat = "yyyy-MM-dd 23:59:59"
            viewModel.filters.dateTo = formatter.string(from: dateTo)
            
            if (selection.count == 0) {
                viewModel.filters.useNature = false
                selection.insert("None")
            }
            
            viewModel.filters.selectedNatures = selection
            viewModel.filters.selectedNaturesString = Array(selection)
            viewModel.filters.selectedNaturesUD = Array(selection).joined(separator: ", ")
            
            if refreshOnExit {
                refreshOnExit = false
                viewModel.refresh()
                print("R - Refreshed via Filters")
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

struct ExpandedFilterSettings_Previews: PreviewProvider {
    static var previews: some View {
        ExpandedFilterSettings(showFilter: .constant(true), viewModel: MainViewModel())
            .previewDevice(PreviewDevice(rawValue: "iPad Pro (11-inch) (3rd generation)"))
            .previewDisplayName("iPad Pro (11-inch) (3rd generation)")
    }
}
