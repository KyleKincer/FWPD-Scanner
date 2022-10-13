//
//  ScannerActivityListView.swift
//  Scanner
//
//  Created by Kyle Kincer on 1/11/22.
//

import SwiftUI

struct ScannerActivityListView: View {
    @ObservedObject var viewModel: ScannerActivityListViewModel
    
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
                    ActivityRowView(activity: $0)
                }
            }.refreshable {
                viewModel.refresh()
            }
            .navigationTitle("Recent Events")
            .navigationBarTitleDisplayMode(.automatic)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ScannerActivityListView(viewModel: ScannerActivityListViewModel())
    }
}
