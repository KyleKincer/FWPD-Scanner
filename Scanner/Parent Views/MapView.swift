//
//  MapView.swift
//  Scanner
//
//  Created by Kyle Kincer on 1/19/22.
//

import SwiftUI
import MapKit

struct MapView: View {
    @Binding var viewModel : MapViewModel
    @Binding var listViewModel: ScannerActivityListViewModel
    let deviceIdiom = UIScreen.main.traitCollection.userInterfaceIdiom
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Map(coordinateRegion: $viewModel.region, showsUserLocation: true, annotationItems: listViewModel.activities) { activity in
                    MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: activity.latitude, longitude: activity.longitude)) {
                        MapAnnotationView(mapView: $viewModel, activity: activity)
                }
            }
            .ignoresSafeArea(.all)
        }
        .mask(LinearGradient(gradient: Gradient(colors: [.black, .black, .black, .clear]), startPoint: .bottom, endPoint: .top))
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView(viewModel: .constant(MapViewModel()), listViewModel: .constant(ScannerActivityListViewModel()))
    }
}
