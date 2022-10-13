//
//  TVMapView.swift
//  ScannerTV
//
//  Created by Nick Molargik on 10/12/22.
//

import SwiftUI
import MapKit

struct TVMapView: View {
    @Binding var viewModel : MapViewModel
    @Binding var listViewModel: ScannerActivityListViewModel
    let deviceIdiom = UIScreen.main.traitCollection.userInterfaceIdiom
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Map(coordinateRegion: $viewModel.region, showsUserLocation: true, annotationItems: listViewModel.activities) { activity in
                MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: activity.latitude, longitude: activity.longitude)) {
                    TVMapAnnotationView(mapView: $viewModel, activity: activity).focusable()
                }
            }
            .ignoresSafeArea(.all)
        }
        .mask(LinearGradient(gradient: Gradient(colors: [.black, .black, .black, .clear]), startPoint: .bottom, endPoint: .top))
    }
}

struct TVMapView_Previews: PreviewProvider {
    static var previews: some View {
        TVMapView(viewModel: .constant(MapViewModel()), listViewModel: .constant(ScannerActivityListViewModel()))
    }
}
