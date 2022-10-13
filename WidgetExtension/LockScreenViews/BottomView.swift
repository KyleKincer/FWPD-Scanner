//
//  BottomView.swift
//  WidgetExtensionExtension
//
//  Created by Nick Molargik on 10/1/22.
//

import SwiftUI

struct BottomView: View {
    @State var state : LatestAttribute.ContentState
    @AppStorage("showDistance") var showDistance = true
    
    var body: some View {
        HStack {
            VStack {
                if (state.activity.nature == "Scanning for Activity") {
                    Text("Scanning for Activity...")
                        .foregroundColor(.white)

                } else if (state.activity.nature == "Scanning Ended") {
                    Text("Scanning Ended...")
                        .foregroundColor(.white)
                    
                } else {
                    if (showDistance && state.activity.distance != nil) {
                        HStack {
                            Text(state.activity.location.capitalized)
                                .font(.system(size: 20))
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                                .padding(.trailing)
                            
                            Image(systemName: "mappin.and.ellipse")
                                .imageScale(.small)
                            
                            Text("\(String(format: "%g", round(10 * state.activity.distance!) / 10)) miles away")
                                .font(.system(size: 10))
                        }

                        Text(state.activity.address)
                            .lineLimit(1)
                            .font(.system(size: 20))
                            .foregroundColor(.secondary)
                            
                    } else {
                        Text(state.activity.address)
                            .lineLimit(1)
                            .font(.system(size: 20))
                            
                        Text(state.activity.location.capitalized)
                            .lineLimit(1)
                            .font(.system(size: 20))
                            .multilineTextAlignment(.leading)
                    }
                }
            }
            
            Spacer()
            
            Image("ScannerIcon")
                .clipShape(Circle())
                .scaleEffect(0.2)
                .frame(width: 50, height: 50)
                .padding(.trailing)
            
        }.padding(.horizontal)
    }
}
