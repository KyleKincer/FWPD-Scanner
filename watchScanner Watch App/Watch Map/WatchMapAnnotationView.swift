//
//  WatchMapAnnotationView.swift
//  watchScanner Watch App
//
//  Created by Nick Molargik on 9/30/22.
//

import SwiftUI
import MapKit

struct WatchMapAnnotationView: View {
    @State private var showDetails = false
    @ObservedObject var viewModel : MainViewModelWatch
    @State var activity: Scanner.Activity
    
    var body: some View {
        ZStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.red)
                .onTapGesture {
                    withAnimation (.linear){
                        showDetails.toggle()
                        viewModel.region.center = CLLocationCoordinate2D(latitude: activity.latitude, longitude: activity.longitude)
                    }
            }
        }
    }
}

struct WatchMapAnnotationView_Previews: PreviewProvider {
    static var previews: some View {
        WatchMapAnnotationView(viewModel: MainViewModelWatch(), activity: Scanner.Activity(id: "1116", timestamp: "06/07/1998 - 01:01:01", nature: "Wild Kyle Appears", address: "5522 Old Dover Blvd", location: "Canterbury Green", controlNumber: "10AD43", longitude: -85.10719687273503, latitude: 41.13135945131842))
            .frame(width: 30, height: 30)
    }
}
