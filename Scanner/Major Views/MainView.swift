//
//  MainView.swift
//  Scanner
//
//  Created by Nick Molargik on 9/28/22.
//

import SwiftUI

struct MainView: View {
    @Environment(\.horizontalSizeClass) var sizeClass
    
    @StateObject var viewModel = MainViewModel()
    @AppStorage("showDistance") var showDistance = true
    @AppStorage("onboarding") var onboarding = true
    
    var body: some View {
        if (onboarding) {
            OnboardingView(viewModel: viewModel)
                .transition(.opacity)
            
        } else {
            VStack {
                if (sizeClass == .compact) {
                    StandardSizeView(viewModel: viewModel) // for iOS devices and compact iPads
                } else {
                    ExpandedSizeView(viewModel: viewModel) // for all other iPads
                }
            }
            .onAppear {
                showDistance = true
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        
        MainView()
            .previewDevice(PreviewDevice(rawValue: "iPhone 13 mini 15.0"))
            .previewDisplayName("iPhone 13 mini")
        MainView()
            .previewDevice(PreviewDevice(rawValue: "iPad Pro (11-inch) (3rd generation)"))
            .previewDisplayName("iPad Pro (11-inch) (3rd generation)")
    }
}
