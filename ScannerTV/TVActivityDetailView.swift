//
//  TVActivityDetailView.swift
//  ScannerTV
//
//  Created by Nick Molargik on 10/12/22.
//

import SwiftUI
import MapKit

struct TVActivityDetailView: View {
    let activity: Scanner.Activity
    @ObservedObject var viewModel: DetailViewModel
    
    init(activity: Scanner.Activity) {
        self.activity = activity
        self.viewModel = DetailViewModel(activity: self.activity)
    }
    
    var body: some View {
        VStack (alignment: .leading) {
            Text(activity.nature == "" ? "Unknown" : activity.nature.capitalized)
                .font(.system(size: 70))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
            
            HStack {
                VStack (alignment: .leading) {
                    Spacer()
                    
                    HStack {
                        Image(systemName: "mappin.and.ellipse")
                        
                        Text(activity.address).padding(.trailing, -8).lineLimit(1)
                        if activity.distance != nil {
                            Text(", \(String(format: "%g", round(10 * activity.distance!) / 10)) mi away")
                        }
                    }
                    
                    Divider()
                    
                    HStack {
                        Image(systemName: "clock")
                        Text("\(activity.timestamp) (").padding(.trailing, -8.5)
                        Text(activity.date ?? Date(), style: .relative).padding(.trailing, -3)
                        Text("ago)")
                    }
                    
                    Divider()
                    
                    HStack {
                        Image(systemName: "location")
                        Text(activity.location)
                    }
                    
                    Spacer()
                }
                
                VStack {
                    
                    Spacer()
                    
                    Map(coordinateRegion: $viewModel.region, interactionModes: .all, showsUserLocation: true, userTrackingMode: $viewModel.userTrackingMode, annotationItems: [activity]) { activity in
                        MapMarker(coordinate: CLLocationCoordinate2D(latitude: activity.latitude, longitude: activity.longitude), tint: .accentColor)
                    }
                    .frame(height: 400, alignment: .top)
                    .cornerRadius(20)
                    .padding(.horizontal)
                    .focusable(false)
                    
                    Spacer()
                    
                }

            }
        }
        .padding()
    }
}

struct TVActivityDetailView_Previews: PreviewProvider {
    static var previews: some View {
        TVActivityDetailView(activity: Scanner.Activity(id: 1116, timestamp: "06/07/1998 - 01:01:01", nature: "Wild Kyle Appears", address: "5522 Old Dover Blvd", location: "Canterbury Green", controlNumber: "10AD43", longitude: -85.10719687273503, latitude: 41.13135945131842))
    }
}
