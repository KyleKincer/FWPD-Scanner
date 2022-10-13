//
//  ContentView.swift
//  watchScanner Watch App
//
//  Created by Nick Molargik on 9/30/22.
//

import SwiftUI

struct WatchMainView: View {
    @StateObject var viewModel = ScannerActivityListViewModel()
    @State var showMap = false

    var body: some View {
        VStack {
            WatchListView(viewModel: viewModel)
        }
    }
}

struct WatchMainView_Previews: PreviewProvider {
    static var previews: some View {
        WatchMainView()
    }
}
