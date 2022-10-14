//
//  ExpandedDetailView.swift
//  Scanner
//
//  Created by Nick Molargik on 9/28/22.
//

import SwiftUI

struct ExpandedDetailView: View {
    @Binding var showMap: Bool
    @State var mapModel: MapViewModel
    @State var viewModel: ScannerActivityListViewModel

    var body: some View {
        VStack {
            ActivityView(showMap: $showMap, viewModel: viewModel)
        }
    }
}
        

struct ExpandedDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ExpandedDetailView(showMap: .constant(false), mapModel: MapViewModel(), viewModel: ScannerActivityListViewModel())
            .previewDevice(PreviewDevice(rawValue: "iPad Pro (11-inch) (3rd generation)"))
            .previewDisplayName("iPad Pro (11-inch) (3rd generation)")
    }
}
