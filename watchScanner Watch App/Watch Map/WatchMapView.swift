//
//  WatchMapView.swift
//  Scanner
//
//  Created by Nick Molargik on 9/30/22.
//

import SwiftUI
import MapKit

struct WatchMapView: View {
    @Binding var viewModel : MapViewModel
    @Binding var listViewModel: ScannerActivityListViewModel
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Map(coordinateRegion: $viewModel.region, showsUserLocation: true, annotationItems: listViewModel.activities) { activity in
                MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: activity.latitude, longitude: activity.longitude)) {
                    WatchMapAnnotationView(mapView: $viewModel, activity: activity)
                }
            }
            .ignoresSafeArea(.all)
        }
    }
}

struct WatchMapView_Previews: PreviewProvider {
    static var previews: some View {
        WatchMapView(viewModel: .constant(MapViewModel()), listViewModel: .constant(ScannerActivityListViewModel()))
    }
}
