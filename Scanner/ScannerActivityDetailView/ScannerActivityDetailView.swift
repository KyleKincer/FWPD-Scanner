//
//  ScannerActivityDetailView.swift
//  Scanner
//
//  Created by Kyle Kincer on 1/13/22.
//

import SwiftUI
import MapKit
import CoreLocation

struct ScannerActivityDetailView: View {
    private let activity: Scanner.Activity
    @ObservedObject var viewModel: ScannerActivityDetailViewModel
    
    
    init(activity: Scanner.Activity) {
        self.activity = activity
        self.viewModel = ScannerActivityDetailViewModel(activity: self.activity)
    }
    
    var body: some View {
        VStack() {
            HStack {
                Image(systemName: "mappin.and.ellipse")
                Text(activity.address).padding(.trailing, -8).lineLimit(1)
                if activity.distance != nil {
                    Text(", \(String(format: "%g", round(10 * activity.distance!) / 10)) mi away")
                }
            }.minimumScaleFactor(0.75)
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
        }
        .padding(.top, 30).padding(.bottom, 15)
        .navigationTitle(activity.nature)
        .navigationBarTitleDisplayMode(.inline)
        ZStack(alignment: .bottom) {
            Map(coordinateRegion: $viewModel.region, interactionModes: .all, showsUserLocation: true, userTrackingMode: $viewModel.userTrackingMode, annotationItems: [activity]) { activity in
                MapMarker(coordinate: CLLocationCoordinate2D(latitude: activity.latitude, longitude: activity.longitude), tint: .accentColor)
            }
            .frame(height: 400, alignment: .top)
            .cornerRadius(10)
            .padding(.horizontal)
            
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
        
        Spacer()
    }
}

//struct ScannerActivityDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        ScannerActivityDetailView()
//    }
//}
