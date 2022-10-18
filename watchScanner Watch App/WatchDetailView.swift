//
//  WatchDetailView.swift
//  watchScanner Watch App
//
//  Created by Nick Molargik on 9/30/22.
//

import SwiftUI
import MapKit
import CoreLocation

struct WatchDetailView: View {
    private let activity: Scanner.Activity
    @ObservedObject var viewModel: DetailViewModel
    
    init(activity: Scanner.Activity) {
        self.activity = activity
        self.viewModel = DetailViewModel(activity: self.activity)
    }
    
    var body: some View {
        
        ZStack {
            
            Map(coordinateRegion: $viewModel.region, interactionModes: .all, showsUserLocation: true, userTrackingMode: $viewModel.userTrackingMode, annotationItems: [activity]) { activity in
                MapMarker(coordinate: CLLocationCoordinate2D(latitude: activity.latitude, longitude: activity.longitude), tint: .red)
                
            }.ignoresSafeArea(.all)
            
            
            VStack {
                ZStack {
                    Rectangle()
                        .frame(width: 195, height: 75)
                        .opacity(0.75)
                        .cornerRadius(10)
                    
                    VStack {
                        HStack {
                            Image(systemName: "mappin.and.ellipse")
                            
                            Text(activity.address)
                                .padding(.trailing, -8)
                                .lineLimit(1)
                                .font(.system(size: 8))
                        }
                        .frame(width: 180)
                        .scaledToFit()
                        
                        if activity.distance != nil {
                            Text(", \(String(format: "%g", round(10 * activity.distance!) / 10)) mi away")
                                .font(.footnote)
                        }
                        
                        HStack {
                            Image(systemName: "clock")
                                .foregroundColor(.orange)
                            
                            Text("\(activity.date ?? Date(), style: .relative) ago")
                                .font(.footnote)
                                .monospacedDigit()
                                .multilineTextAlignment(.center)
                            
                        }
                        
                        HStack {
                            Image(systemName: "location")
                                .foregroundColor(.blue)
                            
                            Text(activity.location)
                                .font(.footnote)
                            
                        }
                    }
                    .foregroundColor(.black)
                    .padding()
                }
                .padding(.top, 75)
            }
        }
    }
}

struct WatchDetailView_Previews: PreviewProvider {
    static var previews: some View {
        WatchDetailView(activity: Scanner.Activity(id: 1116, timestamp: "06/07/1998 - 01:01:01", nature: "Wild Kyle Appears", address: "5522 Old Dover Blvd", location: "Canterbury Green", controlNumber: "10AD43", longitude: -85.10719687273503, latitude: 41.13135945131842))
    }
}

