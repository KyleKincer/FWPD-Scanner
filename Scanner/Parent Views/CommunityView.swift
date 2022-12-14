//
//  CommunityView.swift
//  Scanner
//
//  Created by Kyle Kincer on 12/13/22.
//

import SwiftUI
import SwiftUICharts

struct CommunityView: View {
    @StateObject var communityViewModel = CommunityViewModel()
    
    var body: some View {
        BarChartView(data: communityViewModel.getMostActiveCommenters(), title: "Most Active Commenters", form: ChartForm.extraLarge, dropShadow: false)
            .padding()
    }
}

struct CommunityView_Previews: PreviewProvider {
    static var previews: some View {
        CommunityView()
    }
}
