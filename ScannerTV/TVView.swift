//
//  ContentView.swift
//  ScannerTV
//
//  Created by Nick Molargik on 10/12/22.
//

import SwiftUI

struct TVView: View {
    @AppStorage("onboarding") var onboarding = true
    @State var viewModel = ScannerActivityListViewModel()
    let mapModel = MapViewModel()
    
    var body: some View {
        if (onboarding) {
            TVOnboardingView()
                .transition(.opacity)
                .onAppear {
                    viewModel.refresh()
                    
                }
        } else {
            
            VStack {
                TVMainView(viewModel: viewModel)
                    .edgesIgnoringSafeArea(.all)
                    .onAppear {
                        viewModel.refresh()
                    }
            }
            .padding()
        }
    }
}

struct TVView_Previews: PreviewProvider {
    static var previews: some View {
        TVView()
    }
}
