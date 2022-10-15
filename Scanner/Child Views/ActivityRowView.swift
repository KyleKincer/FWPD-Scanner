//
//  ActivityCell.swift
//  Scanner
//
//  Created by Kyle Kincer on 1/17/22.
//

import SwiftUI

struct ActivityRowView: View {
    let activity: Scanner.Activity
    @AppStorage("showDistance") var showDistance = true
    
    var body: some View {
        NavigationLink(destination: {ScannerActivityDetailView(activity: activity)}) {
            VStack(spacing: 5) {
                if (showDistance && activity.distance != nil) {
                    HStack {
                        Text(activity.nature.capitalized)
                            .font(.body)
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.leading)
                            .lineLimit(1)
                            .minimumScaleFactor(0.75)
                        
                        Spacer()
                        
                        Text("\(activity.date ?? Date(), style: .relative)")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.trailing)
                            .lineLimit(1)
                    }
                    
                    HStack {
                        Image(systemName: "mappin.and.ellipse")
                        Text("\(String(format: "%g", round(10 * activity.distance!) / 10)) miles away")
                        
                        Spacer()
                        
                        Text(activity.location.capitalized)
                        
                    }
                    .font(.footnote)
                    
                    HStack {
                        Text(activity.address.capitalized)
                            .font(.footnote)
                        Spacer()
                    }
                    .font(.footnote)
                } else {
                    
                    HStack {
                        Text(activity.nature.capitalized)
                            .font(.body)
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.leading)
                            .lineLimit(1)
                            .minimumScaleFactor(0.75)
                        
                        Spacer()
                    }
                    
                    HStack {
                        Text("\(activity.date ?? Date(), style: .relative) ago")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.trailing)
                            .lineLimit(1)
                        
                        Spacer()
                        
                    }
                    
                    HStack {
                        Text(activity.address.capitalized)
                            .font(.footnote)
                        Spacer()
                    }
                    
                    HStack {
                        Text(activity.location)
                            .font(.footnote)
                        
                        Spacer()
                    }
                }
            }
        }
    }
}

struct ActivityRowView_Previews: PreviewProvider {
    static var previews: some View {
        ActivityRowView(activity: Scanner.Activity(id: 1116, timestamp: "06/07/1998 - 01:01:01", nature: "Wild Kyle Appears", address: "5522 Old Dover Blvd", location: "Canterbury Green", controlNumber: "10AD43", longitude: -85.10719687273503, latitude: 41.13135945131842))
            .frame(width: 200, height: 100)
    }
}
