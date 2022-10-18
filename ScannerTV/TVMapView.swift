//
//  TVMapView.swift
//  ScannerTV
//
//  Created by Nick Molargik on 10/12/22.
//

import SwiftUI
import MapKit

struct TVMapView: View {
    @State var mapModel = MapViewModel()
    @ObservedObject var viewModel: MainViewModel
    let deviceIdiom = UIScreen.main.traitCollection.userInterfaceIdiom
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Map(coordinateRegion: $mapModel.region, showsUserLocation: true, annotationItems: viewModel.activities) { activity in
                MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: activity.latitude, longitude: activity.longitude)) {
                    TVMapAnnotationView(viewModel: viewModel, activity: activity).focusable()
                }
            }
            .ignoresSafeArea(.all)
        }
        .mask(LinearGradient(gradient: Gradient(colors: [.black, .black, .black, .clear]), startPoint: .bottom, endPoint: .top))
    }
}

struct TVMapView_Previews: PreviewProvider {
    static var previews: some View {
        TVMapView(viewModel: MainViewModel())
    }
}
