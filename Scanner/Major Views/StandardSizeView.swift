//
//  StandardViewStyle.swift
//  Scanner
//
//  Created by Nick Molargik on 9/28/22.
//

import SwiftUI

struct StandardSizeView: View {
    @ObservedObject var viewModel: MainViewModel
    @State var showFilter = false
    @State var showNotificationSheet = false
    @State var showMap = false
    @State var showDebug = false
    @State var showLocationDisclaimer = false
    
    var body: some View {
        VStack {
            StandardNavBarView(showNotificationSheet: $showNotificationSheet, showFilter: $showFilter, showMap: $showMap, showLocationDisclaimer: $showLocationDisclaimer, viewModel: viewModel)
            
            ActivityView(showMap: $showMap, viewModel: viewModel
            )
            
        }.sheet(isPresented: $showFilter) {
            if #available(iOS 16.0, *) {
                FilterSettings(viewModel: viewModel)
                    .presentationDetents([.fraction(0.8)])
            } else {
                FilterSettings(viewModel: viewModel)
            }
        }
        
//        .fullScreenCover(isPresented: $showNotificationSheet) {
//            if #available(iOS 16.1, *) {
//                NewNotificationSettingsView(viewModel: viewModel, showNotificationSheet: $showNotificationSheet)
//            } else {
//                OldNotificationSettingsView(viewModel: viewModel, showNotificationSheet: $showNotificationSheet)
//            }
//        }
        
        .sheet(isPresented: $showNotificationSheet) {
            NotificationsComingView()
        }

        .sheet(isPresented: $showLocationDisclaimer) {
            if #available(iOS 16.1, *) {
                LocationDisclaimerView()
                    .presentationDetents([.fraction(0.4)])
            } else {
                LocationDisclaimerView()
            }
        }
    }
}

struct StandardSizeView_Previews: PreviewProvider {
    static var previews: some View {
        StandardSizeView(viewModel: MainViewModel(), showMap: false)
    }
}
