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
    @ObservedObject var viewModel : ScannerActivityListViewModel
    @Binding var activity : Scanner.Activity
    @AppStorage("showDistance") var showDistance = true
    
    var body: some View {
        VStack {
            Group {
                Text(activity.nature)
                    .font(.largeTitle)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer()
                
                Button (action: {
                    activity.bookmarked.toggle()
                }, label: {
                    VStack {
                        Text(activity.bookmarked ? "Remove Bookmark" : "Bookmark")
                        if (activity.bookmarked) {
                            Image(systemName: "bookmark.fill")
                        } else {
                            Image(systemName: "bookmark")
                        }
                    }
                    .foregroundColor(activity.bookmarked ? .red : .blue)
                })
                .padding(.bottom)
            }
            
            Group {
                HStack {
                    Image(systemName: "info.circle")
                    Text(activity.controlNumber)
                }
                
                Divider()
                
                HStack {
                    Image(systemName: "mappin.and.ellipse")
                    Text(activity.address).padding(.trailing, -8).lineLimit(1)
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
                
                Divider()
                
                if (showDistance) {
                    HStack {
                        Text("\(String(format: "%g", round(10 * (activity.distance ?? 0)) / 10)) miles away")
                    }
                }
                
                Spacer()
            }
            
            DetailMapView(viewModel: viewModel, activity: activity)
        }
        .padding(.top, 30).padding(.bottom, 15)
        .navigationBarTitleDisplayMode(.inline)
        .transition(.slide)
    }
}

struct ScannerActivityDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ScannerActivityDetailView(viewModel: ScannerActivityListViewModel(), activity: .constant(Scanner.Activity(id: 1116, timestamp: "06/07/1998 - 01:01:01", nature: "Wild Kyle Appears", address: "5522 Old Dover Blvd", location: "Canterbury Green", controlNumber: "10AD43", longitude: -85.10719687273503, latitude: 41.13135945131842)))
    }
}
