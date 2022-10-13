//
//  WatchMapAnnotationView.swift
//  watchScanner Watch App
//
//  Created by Nick Molargik on 9/30/22.
//

import SwiftUI
import MapKit

struct WatchMapAnnotationView: View {
    @State private var showDetails = false
    @ObservedObject var viewModel : ScannerActivityListViewModel
    @State var activity: Scanner.Activity
    
    var body: some View {
        ZStack {
            Rectangle()
                .frame(width: 190, height: 100)
                .foregroundColor(.white)
                .opacity(showDetails ? 0.75 : 0)
                .cornerRadius(15)
            
            VStack {
                HStack {
                    Text(activity.nature)
                        .padding(.trailing, -8)
                        .lineLimit(1)
                        .foregroundColor(.black)
                        .opacity(showDetails ? 1: 0)
                        .font(.system(size: 10))
                }
                HStack {
                    Text(activity.address)
                        .padding(.trailing, -8)
                        .lineLimit(1)
                        .foregroundColor(.black)
                        .font(.system(size: 10))
                }
                .opacity(showDetails ? 1 : 0)
                
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.red)
                    .onTapGesture {
                        withAnimation (.linear){
                            showDetails.toggle()
                            viewModel.region.center = CLLocationCoordinate2D(latitude: activity.latitude, longitude: activity.longitude)
                        }
                    }
                
                HStack {
                    Text(activity.timestamp)
                        .padding(.trailing, -8.5)
                        .foregroundColor(.black)
                        .font(.system(size: 12))
                }
                .opacity(showDetails ? 1 : 0)
            }
        }
    }
}

struct WatchMapAnnotationView_Previews: PreviewProvider {
    static var previews: some View {
        WatchMapAnnotationView(viewModel: ScannerActivityListViewModel(), activity: Scanner.Activity(id: 1116, timestamp: "06/07/1998 - 01:01:01", nature: "Wild Kyle Appears", address: "5522 Old Dover Blvd", location: "Canterbury Green", controlNumber: "10AD43", longitude: -85.10719687273503, latitude: 41.13135945131842))
            .frame(width: 30, height: 30)
    }
}
