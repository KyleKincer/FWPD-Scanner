//
//  StandardViewStyle.swift
//  Scanner
//
//  Created by Nick Molargik on 9/28/22.
//

import SwiftUI

struct StandardSizeView: View {
    @ObservedObject var viewModel: MainViewModel
    @State var showCoffee = false
    @State var showFilter = false
    @State var showScanMenu = false
    @State var showMap = false
    @State var showDebug = false
    @State var showLocationDisclaimer = false
    
    var body: some View {
        VStack {
            StandardNavBarView(showScanMenu: $showScanMenu, showFilter: $showFilter, showMap: $showMap, showCoffee: $showCoffee, showLocationDisclaimer: $showLocationDisclaimer, viewModel: viewModel)
            
            ActivityView(showMap: $showMap, viewModel: viewModel)
            
        }.sheet(isPresented: $showCoffee) {
            if #available(iOS 16.0, *) {
                CoffeeView(showCoffee: $showCoffee)
                    .presentationDetents([.fraction(0.6)])
            } else {
                CoffeeView(showCoffee: $showCoffee)
            }
        }.sheet(isPresented: $showFilter) {
            if #available(iOS 16.0, *) {
                FilterSettings(viewModel: viewModel)
                    .presentationDetents([.fraction(0.8)])
            } else {
                FilterSettings(viewModel: viewModel)
            }
        }
        
//        .sheet(isPresented: $showScanMenu) {
//            if #available(iOS 16.1, *) {
//                ScanModeSettingsView()
//                    .presentationDetents([.fraction(0.8)])
//            } else {
//                ScanModeUpgradeView()
//            }
//        }
        
        .sheet(isPresented: $showScanMenu) {
            if #available(iOS 16.1, *) {
                ScanModeComingView()
                    .presentationDetents([.fraction(0.5)])
            } else {
                ScanModeComingView()
            }
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
        StandardSizeView(viewModel: MainViewModel(), showCoffee: false, showMap: false)
    }
}
