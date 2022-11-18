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
    @ObservedObject var viewModel: WatchViewModel
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            Map(coordinateRegion: $mapModel.region, showsUserLocation: true, annotationItems: viewModel.activities) { activity in
                MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: activity.latitude, longitude: activity.longitude)) {
                    WatchMapAnnotationView(viewModel: viewModel, activity: activity)
                }
            }
            .ignoresSafeArea(.all)
            
            VStack {
                HStack {
                    
                    
                    ZStack {
                        Circle()
                            .foregroundColor(.blue)
                        if (viewModel.isLoading) {
                            ProgressView()
                        } else {
                            Image(systemName: "goforward.plus")
                                .foregroundColor(.white)
                                .font(.system(size: 30))
                                .padding(.bottom, 2)
                                
                        }
                    }
                    
                    .frame(width: 45, height: 45)
                    .onTapGesture {
                        if (!viewModel.isLoading) {
                            withAnimation (.easeInOut(duration: 0.5)){
                                viewModel.playHaptic()
                                viewModel.getMoreActiviesWatch()
                            }
                        }
                    }
                }.padding(.leading)
                    .padding(.trailing, 4)
            }
            
        }
    }
}

struct WatchMapView_Previews: PreviewProvider {
    static var previews: some View {
        WatchMapView(viewModel: WatchViewModel())
    }
}
