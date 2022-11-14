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
    @AppStorage("selectedNatures") var selectedNatures = String()
    
    var body: some View {
        VStack {
            HStack {
                Button {
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
                .disabled(selection.count == 0)
            }
            .padding()
            
            List(selection: $selection, content: {
                ForEach(viewModel.natures, id: \.name) { nature in
                    Text(nature.name.capitalized)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                }
            })
            .environment(\.editMode, .constant(EditMode.active))
            .navigationBarTitle(Text("Types"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                    
                    Button {
                        selection.removeAll()
                    } label: {
                        Text("Clear")
                    }
                }
            }
            .onAppear {
                let selectionArray = selectedNatures.components(separatedBy: ", ")
                selection = Set(selectionArray)
                viewModel.selectedNatures = selection
                
            }
            .onDisappear {
                viewModel.selectedNatures = selection
                viewModel.selectedNaturesString = Array(selection)
                selectedNatures = Array(selection).joined(separator: ", ")
            }
        }
        .interactiveDismissDisabled()
    }
}

struct NaturesList_Previews: PreviewProvider {
    static var previews: some View {
        NaturesList(viewModel: MainViewModel(), selection: MainViewModel().selectedNatures)
    }
}
