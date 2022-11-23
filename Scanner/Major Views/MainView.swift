//
//  MainView.swift
//  Scanner
//
//  Created by Nick Molargik on 9/28/22.
//

import SwiftUI

struct MainView: View {
    @Environment(\.horizontalSizeClass) var sizeClass
    @EnvironmentObject private var appDelegate: AppDelegate
    @State var viewModel : MainViewModel
    @AppStorage("showDistance") var showDistance = true
    @AppStorage("onboarding") var onboarding = true
    @State private var showFilter = false
    @State private var showMap = false
    @State private var showNotificationView = false
    @State private var showLocationDisclaimer = false
    
    var body: some View {
        if (onboarding) {
            OnboardingView(viewModel: viewModel)
                .transition(.opacity)
            
        } else {
            VStack {
                if (sizeClass == .compact) {
                    StandardNavBarView(showNotificationSheet: $showNotificationView, showFilter: $showFilter, showMap: $showMap, showLocationDisclaimer: $showLocationDisclaimer, viewModel: viewModel)
                    
                    ActivityView(showMap: $showMap, viewModel: viewModel)
                        .environmentObject(appDelegate)
                    
                } else {
                    VStack {
                        ExpandedNavBarView(showFilter: $showFilter, showMap: $showMap, showLocationDisclaimer: $showLocationDisclaimer, showNotificationView: $showNotificationView, viewModel: viewModel)
                        
                        Divider()
                            .padding(0)
                        
                        ActivityView(showMap: $showMap, viewModel: viewModel)
                            .environmentObject(appDelegate)
                            .padding(.top, -8)
                    }
                }
            }
            .onAppear {
                showDistance = true
            }
            .sheet(isPresented: $showFilter) {
                if #available(iOS 16.0, *) {
                    if (sizeClass == .compact) {
                        FilterSettings(viewModel: viewModel)
                            .presentationDetents([.fraction(0.8)])
                    } else {
                        ExpandedFilterSettings(viewModel: viewModel)
                    }
                } else {
                    if (sizeClass == .compact) {
                        FilterSettings(viewModel: viewModel)
                    } else {
                        ExpandedFilterSettings(viewModel: viewModel)
                    }
                }
            }
            
            .fullScreenCover(isPresented: $showNotificationView) {
                if #available(iOS 16.1, *) {
                    NewNotificationSettingsView(viewModel: viewModel, showNotificationView: $showNotificationView)
                } else {
                    OldNotificationSettingsView(viewModel: viewModel, showNotificationView: $showNotificationView)
                }
            }
            
            .sheet(isPresented: $showLocationDisclaimer) {
                if #available(iOS 16.1, *) {
                    LocationDisclaimerView()
                        .presentationDetents([.fraction(0.5)])
                } else {
                    LocationDisclaimerView()
                }
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        
        MainView(viewModel: MainViewModel())
            .previewDevice(PreviewDevice(rawValue: "iPhone 13 mini"))
            .previewDisplayName("iPhone 13 mini")
        MainView(viewModel: MainViewModel())
            .previewDevice(PreviewDevice(rawValue: "iPad Pro (11-inch) (3rd generation)"))
            .previewDisplayName("iPad Pro (11-inch) (3rd generation)")
    }
}
