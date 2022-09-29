//
//  MapView.swift
//  Scanner
//
//  Created by Kyle Kincer on 1/19/22.
//

import SwiftUI
import MapKit

struct MapView: View {
    @ObservedObject var viewModel = MapViewModel()
    @ObservedObject var listViewModel: ScannerActivityListViewModel
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .topTrailing) {
                Map(coordinateRegion: $viewModel.region, showsUserLocation: true, annotationItems: listViewModel.activities) { activity in
                    MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: activity.latitude, longitude: activity.longitude)) {
                        NavigationLink {
                            ScannerActivityDetailView(activity: activity)
                        } label: {
                            Image(systemName: "exclamationmark.triangle")
                                .foregroundColor(.red)
                        }
                        
                    }
                }   .ignoresSafeArea(edges: .top)
                    .ignoresSafeArea(edges: .horizontal)
            }
        }
    }
}

//struct MapView_Previews: PreviewProvider {
//    static var previews: some View {
//        MapView()
//    }
//}
