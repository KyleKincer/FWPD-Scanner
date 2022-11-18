//
//  ContentView.swift
//  watchScanner Watch App
//
//  Created by Nick Molargik on 9/30/22.
//

import SwiftUI

struct WatchMainView: View {
    @StateObject var viewModel = WatchViewModel()
    @State var showMap = false
    @AppStorage("onboarding") var onboarding = true

    var body: some View {
        VStack {
            if (onboarding) {
                WatchOnboardingView(viewModel: viewModel)
                    .transition(.slide)
            } else {
                WatchListView(viewModel: viewModel)
                    .transition(.slide)
            }
        }
    }
}

struct WatchMainView_Previews: PreviewProvider {
    static var previews: some View {
        WatchMainView()
    }
}
