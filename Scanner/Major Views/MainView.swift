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
    @State private var showFilter = false
    @State private var showMap = false
    @State private var showNotificationView = false
    @State private var showLocationDisclaimer = false
    @State private var showProfileView = false
    
    var body: some View {
        if (viewModel.onboarding) {
            OnboardingView(viewModel: $viewModel)
                .transition(.opacity)
            
        } else {
            VStack {
                if (sizeClass == .compact) {
                    StandardNavBarView(showNotificationSheet: $showNotificationView, showFilter: $showFilter, showMap: $showMap, showLocationDisclaimer: $showLocationDisclaimer, showProfileView: $showProfileView, viewModel: viewModel)
                    
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
                        
                        Divider()
                            .padding(0)
                        
                        SwiftUIBannerAd(adPosition: .bottom, adUnitId: Constants.appID)
                            .ignoresSafeArea()
                            .frame(maxHeight: 40)
                        
                    }
                }
            }
            .onAppear {
                showDistance = true
            }
            
            .fullScreenCover(isPresented: $showFilter) {
                if #available(iOS 16.0, *) {
                    if (sizeClass == .compact) {
                        SettingsView(showFilter: $showFilter, viewModel: viewModel)
                            .presentationDetents([.fraction(0.8)])
                    } else {
                        ExpandedFilterSettings(showFilter: $showFilter, viewModel: viewModel)
                    }
                } else {
                    if (sizeClass == .compact) {
                        SettingsView(showFilter: $showFilter, viewModel: viewModel)
                    } else {
                        ExpandedFilterSettings(showFilter: $showFilter, viewModel: viewModel)
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
            
            .fullScreenCover(isPresented: $showProfileView) {
                ProfileView(viewModel: $viewModel, showProfileView: $showProfileView)
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
