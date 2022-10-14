//
//  WatchMapView.swift
//  Scanner
//
//  Created by Nick Molargik on 9/30/22.
//

import SwiftUI
import MapKit

struct WatchMapView: View {
    @State var mapModel = MapViewModel()
    @ObservedObject var viewModel: ScannerActivityListViewModel
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Map(coordinateRegion: $mapModel.region, showsUserLocation: true, annotationItems: viewModel.activities) { activity in
                MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: activity.latitude, longitude: activity.longitude)) {
                    WatchMapAnnotationView(viewModel: viewModel, activity: activity)
                }
            }
            .ignoresSafeArea(.all)
        }
    }
}

struct WatchMapView_Previews: PreviewProvider {
    static var previews: some View {
        WatchMapView(viewModel: ScannerActivityListViewModel())
    }
}
