//
//  NaturesList.swift
//  Scanner
//
//  Created by Kyle Kincer on 4/8/22.
//

import SwiftUI

struct NaturesList: View {
    var viewModel: ScannerActivityListViewModel
    @State var selection = Set<Int>()
    @Environment(\.dismiss) var dismiss
    var body: some View {
        VStack {
            HStack {
                Button {
                    dismiss()
                } label: {
                    Text("Close")
                }
                
                Spacer()
                
                Text("Select Activites")
                    .fontWeight(.semibold)
                    .italic()
                
                Spacer()
                
                Button {
                    selection.removeAll()
                } label: {
                    Text("Clear")
                }
            }
            .padding()
            
            List(selection: $selection, content: {
                ForEach(viewModel.natures) { nature in
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
                    Button {
                        selection.removeAll()
                    } label: {
                        Text("Clear")
                    }
                }
            }
            .onAppear {
                selection = viewModel.selectedNatures
            }
            .onDisappear {
                viewModel.selectedNatures = selection
            }
        }
        .interactiveDismissDisabled()
    }
}

struct NaturesList_Previews: PreviewProvider {
    static var previews: some View {
        NaturesList(viewModel: ScannerActivityListViewModel(), selection: ScannerActivityListViewModel().selectedNatures)
    }
}
