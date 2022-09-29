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
    
    var body: some View {
        NavigationView {
            List(viewModel.activities) {
                if viewModel.isLoading {
                    if $0 == viewModel.activities.first {
                        HStack {
                            Spacer()
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                            Spacer()
                        }
                    }
                } else {
                    ActivityCell(activity: $0)
                }
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
