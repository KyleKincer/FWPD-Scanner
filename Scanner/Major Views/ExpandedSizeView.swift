//
//  ExpandedViewStyle.swift
//  Scanner
//
//  Created by Nick Molargik on 9/28/22.
//

import SwiftUI

struct ExpandedSizeView: View {
    @ObservedObject var viewModel: MainViewModel
    @State private var showFilter = false
    @State private var showScanMenu = false
    @State private var showMap = false
    @State private var showLocationDisclaimer = false

    var body: some View {
        VStack {
            ExpandedNavBarView(showScanMenu: $showScanMenu, showFilter: $showFilter, showMap: $showMap, showLocationDisclaimer: $showLocationDisclaimer, viewModel: viewModel)
            
            Divider()
                .padding(0)
            
            ActivityView(showMap: $showMap, viewModel: viewModel)
                .padding(.top, -8)
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
            VStack {
                Text("Activity Filters")
                    .fontWeight(.black)
                    .italic()
                    .font(.largeTitle)
                    .shadow(radius: 2)
                    .foregroundColor(Color("ModeOpposite"))
                    .padding(.top)
                
                ExpandedFilterSettings(viewModel: viewModel)
            }
            
        }
    }
}

struct ExpandedSizeView_Previews: PreviewProvider {
    static var previews: some View {
        ExpandedSizeView(viewModel: MainViewModel())
            .previewDevice(PreviewDevice(rawValue: "iPad Pro (11-inch) (3rd generation)"))
            .previewDisplayName("iPad Pro (11-inch) (3rd generation)")
    }
}
