//
//  NaturesList.swift
//  Scanner
//
//  Created by Kyle Kincer on 4/8/22.
//

import SwiftUI

struct NaturesList: View {
    var viewModel: MainViewModel
    @State var selection = Set<String>()
    @Environment(\.dismiss) var dismiss
    @Environment(\.editMode) private var editMode
    @State var tenSet = Set<String>()
    @State var showNatureAlert = false
    @State private var searchText = ""
    
    var body: some View {
        VStack {
            HStack {
                Button {
                    if (selection.count == 0) {
                        viewModel.useNature = false
                        selection.insert("None")
                    }
                    viewModel.refresh()
                    dismiss()
                } label: {
                    Text("Apply")
                }
                
                Spacer()
                           
                Text("Select Natures")
                    .fontWeight(.semibold)
                    .italic()
                
                Spacer()
                
                Button {
                    selection.removeAll()
                } label: {
                    Text("Clear")
                }
                .disabled(selection.count == 0 || selection.first == "None")
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
                
                .onChange(of: selection, perform: { latestSelection in
                    if (latestSelection.count == 10) {
                        tenSet = latestSelection
                    }
                    if (latestSelection.count >= 11) {
                        showNatureAlert = true
                        selection = tenSet
                    }
                    
                })
            })
            .environment(\.editMode, .constant(EditMode.active))
            .navigationBarTitle(Text("Types"))
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                let selectionArray = viewModel.selectedNaturesUD.components(separatedBy: ", ")
                selection = Set(selectionArray)
                viewModel.selectedNatures = selection
                
            }
            .onDisappear {
                viewModel.selectedNatures = selection
                viewModel.selectedNaturesString = Array(selection)
                viewModel.selectedNaturesUD = Array(selection).joined(separator: ", ")
            }
        }
        .interactiveDismissDisabled()
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

struct NaturesList_Previews: PreviewProvider {
    static var previews: some View {
        NaturesList(viewModel: MainViewModel(), selection: MainViewModel().selectedNatures)
    }
}
