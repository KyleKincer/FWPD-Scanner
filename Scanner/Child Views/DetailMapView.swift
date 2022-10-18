//
//  DetailMapView.swift
//  Scanner
//
//  Created by Nick Molargik on 10/16/22.
//

import SwiftUI
import MapKit

struct DetailMapView: View {
    @State var viewModel: MainViewModel
    @State var activity : Scanner.Activity
    var body: some View {
        ZStack(alignment: .bottom) {
            Map(coordinateRegion: $viewModel.region, interactionModes: .all, showsUserLocation: true, userTrackingMode: .none, annotationItems: [activity]) { activity in
                MapMarker(coordinate: CLLocationCoordinate2D(latitude: activity.latitude, longitude: activity.longitude), tint: .accentColor)
            }
            
            Button() {
                let url = URL(string: "maps://?saddr=&daddr=\(activity.latitude),\(activity.longitude)")
                if UIApplication.shared.canOpenURL(url!) {
                    UIApplication.shared.open(url!, options: [:], completionHandler: nil)
                }
            } label: {
                ZStack{
                    RoundedRectangle(cornerRadius: 15)
                    HStack {
                        Text("Open in Maps").fontWeight(.semibold)
                        Image(systemName: "arrowshape.turn.up.right")
                    }
                    .tint(.white)
                }.frame(width: 200, height: 45)
                    .padding(.bottom)
            }
        }
    }
}

struct DetailMapView_Previews: PreviewProvider {
    static var previews: some View {
        DetailMapView(viewModel: MainViewModel(), activity: Scanner.Activity(id: 1116, timestamp: "06/07/1998 - 01:01:01", nature: "Wild Kyle Appears", address: "5522 Old Dover Blvd", location: "Canterbury Green", controlNumber: "10AD43", longitude: -85.10719687273503, latitude: 41.13135945131842))
    }
}
