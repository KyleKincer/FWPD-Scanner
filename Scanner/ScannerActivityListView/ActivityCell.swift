//
//  ActivityCell.swift
//  Scanner
//
//  Created by Kyle Kincer on 1/17/22.
//

import SwiftUI

struct ActivityCell: View {
    let activity: Scanner.Activity
    var body: some View {
        NavigationLink(destination: {ScannerActivityDetailView(activity: activity)}) {
            VStack(spacing: 5) {
                
                HStack {
//                    Image(systemName: "info.circle")
//                        .frame(height: 25)
                    Text(activity.nature.capitalized)
                        .font(.body)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.leading)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                    Spacer()
                    Text(activity.date ?? Date(), style: .relative)
                        .font(.footnote)
                        .multilineTextAlignment(.trailing)
                        .lineLimit(1)
                }
                
                if activity.distance != nil {
                    HStack {
                        Text(activity.address)
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                            .font(.footnote)
                        Spacer()
                        Image(systemName: "mappin.and.ellipse").imageScale(.small)
                        Text("\(String(format: "%g", round(10 * activity.distance!) / 10)) miles away")
                            .font(.footnote)
                    }
                    HStack {
                        Spacer()
                        Text(activity.location.capitalized)
                    }   .font(.footnote)
                        .multilineTextAlignment(.leading)
                } else {
                    HStack {
                        Text(activity.address)
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                        Spacer()
                        Text(activity.location.capitalized)
                    }   .font(.footnote)
                        .multilineTextAlignment(.leading)
                }
            }
        }
    }
}
