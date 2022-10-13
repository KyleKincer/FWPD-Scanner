//
//  ExpandedViewStyle.swift
//  Scanner
//
//  Created by Nick Molargik on 9/28/22.
//

import SwiftUI

struct ExpandedSizeView: View {
    @ObservedObject var viewModel: ScannerActivityListViewModel
    @ObservedObject var mapModel: MapViewModel
    @State private var showCoffee = false
    @State private var showFilter = false
    @State private var showScanMenu = false
    @State private var showMap = false
    @State private var showLocationDisclaimer = false

    var body: some View {
        VStack {
            ExpandedNavBarView(showScanMenu: $showScanMenu, showFilter: $showFilter, showMap: $showMap, showCoffee: $showCoffee, showLocationDisclaimer: $showLocationDisclaimer, viewModel: viewModel)
            
            Divider()
                .padding(0)
            
            ActivityView(showMap: $showMap, viewModel: viewModel)
                .padding(.top, -8)
        }
        .sheet(isPresented: $showCoffee) {
            if #available(iOS 16.0, *) {
                CoffeeView(showCoffee: $showCoffee)
                    .presentationDetents([.fraction(0.1)])
            } else {
                CoffeeView(showCoffee: $showCoffee)
            }
        }
        .sheet(isPresented: $showLocationDisclaimer) {
            if #available(iOS 16.0, *) {
                LocationDisclaimerView()
                    .presentationDetents([.fraction(0.1)])
            } else {
                LocationDisclaimerView()
            }
        }
        .sheet(isPresented: $showFilter) {
            ExpandedFilterSettings(viewModel: viewModel)
        }
    }
}

struct ExpandedSizeView_Previews: PreviewProvider {
    static var previews: some View {
        ExpandedSizeView(viewModel: ScannerActivityListViewModel(), mapModel: MapViewModel())
            .previewDevice(PreviewDevice(rawValue: "iPad Pro (11-inch) (3rd generation)"))
            .previewDisplayName("iPad Pro (11-inch) (3rd generation)")
    }
}
