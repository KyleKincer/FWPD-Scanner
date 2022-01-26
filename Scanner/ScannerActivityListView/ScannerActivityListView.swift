//
//  ScannerActivityListView.swift
//  Scanner
//
//  Created by Kyle Kincer on 1/11/22.
//

import SwiftUI

struct ScannerActivityListView: View {
    @ObservedObject var viewModel: ScannerActivityListViewModel
    @State var showingLocationSettingsPopover = false
    @State var radius = 1.0
    @State var isEditing = false
    @State var isLoading = true
    
    var body: some View {
        NavigationView {
            List(viewModel.activities) { activity in
                ActivityCell(activity: activity)
            }.refreshable {
                viewModel.refresh()
            }
            .listStyle(InsetListStyle())
            .navigationTitle("FWPD Scanner")
            .navigationBarTitleDisplayMode(.automatic)
        }.popover(isPresented: $showingLocationSettingsPopover) {
            Spacer()
            VStack {
                Text("Maximum Search Radius:")
                HStack {
                    Slider(value: $radius,
                           in: 0.1...20,
                           step: 0.1,
                           label: { Text("Maximum Distance") },
                           onEditingChanged: { editing in isEditing = editing})
                        .padding()
                    Text("\(Double(round(10 * radius)) / 10)" + (radius > 1 ? " miles" : " mile"))
                }.padding(.horizontal)
            }
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = ScannerActivityListViewModel()
        ScannerActivityListView(viewModel: viewModel)
            .preferredColorScheme(.dark)
    }
}
