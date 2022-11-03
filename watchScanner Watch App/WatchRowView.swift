//
//  WatchRowView.swift
//  watchScanner Watch App
//
//  Created by Nick Molargik on 9/30/22.
//

import SwiftUI

struct WatchRowView: View {
    let activity: Scanner.Activity
    var body: some View {
        NavigationLink(destination: {WatchDetailView(activity: activity)}) {
            VStack(alignment: .center) {
                    Text(activity.nature == "" ? "Unknown" : activity.nature.capitalized)
                        .font(.body)
                        .fontWeight(.semibold)
                        .lineLimit(1)
                        .padding(.horizontal)
                                  
                Text(activity.date ?? Date(), style: .relative)
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                        .padding(.horizontal)
                
                Text(activity.address)
                    .lineLimit(1)
                    .padding(.horizontal)
            }
        }
        .navigationTitle("Scanner")
    }
}

struct WatchRowView_Previews: PreviewProvider {
    static var previews: some View {
        WatchRowView(activity: Scanner.Activity(id: 1116, timestamp: "06/07/1998 - 01:01:01", nature: "Wild Kyle Appears", address: "5522 Old Dover Blvd", location: "Canterbury Green", controlNumber: "10AD43", longitude: -85.10719687273503, latitude: 41.13135945131842))
    }
}
