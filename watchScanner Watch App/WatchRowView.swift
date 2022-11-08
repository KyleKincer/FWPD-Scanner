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
        VStack(alignment: .center) {
            NavigationLink(destination: {WatchDetailView(activity: activity)}) {
                VStack {
                    HStack {
                        Spacer()
                        
                        Text(activity.nature == "" ? "Unknown" : activity.nature.capitalized)
                            .font(.system(size: 12))
                            .fontWeight(.semibold)
                            .lineLimit(1)
                            .padding(.horizontal)
                        
                        Spacer()
                        
                    }
                    
                    HStack {
                        Spacer()
                        
                        Text(activity.address)
                            .lineLimit(1)
                            .font(.system(size: 11))
                            .padding(.horizontal)
                        
                        Spacer()
                        
                    }
                    
                    HStack {
                        Spacer()
                        
                        Text("\(activity.date ?? Date(), style: .relative) ago")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                            .padding(.horizontal)
                        
                        Spacer()
                        
                    }
                }
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
