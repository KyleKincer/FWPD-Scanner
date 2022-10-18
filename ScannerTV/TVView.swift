//
//  ContentView.swift
//  ScannerTV
//
//  Created by Nick Molargik on 10/12/22.
//

import SwiftUI

struct TVView: View {
    @AppStorage("onboarding") var onboarding = true
    @StateObject var viewModel = MainViewModel()
    
    var body: some View {
        if (onboarding) {
            TVOnboardingView()
                .transition(.opacity)
            
        } else {
            
            VStack {
                TVMainView(viewModel: viewModel)
                    .edgesIgnoringSafeArea(.all)
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
