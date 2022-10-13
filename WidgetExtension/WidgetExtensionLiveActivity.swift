//
//  WidgetExtensionLiveActivity.swift
//  WidgetExtension
//
//  Created by Nick Molargik on 10/1/22.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct WidgetExtensionLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: LatestAttribute.self) { context in
            // Lock screen live activity
            LockScreenView(state: context.state)
            
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI
                DynamicIslandExpandedRegion(.leading) {
                    if (context.state.activity.nature != "Scanning for Activity" && context.state.activity.nature != "Scanning Ended") {
                        VStack {
                            Text("\(String(format: "%g", round(10 * (context.state.activity.distance ?? 0)) / 10)) miles")
                                .font(.subheadline)
                            Image(systemName: "mappin.and.ellipse")
                                .foregroundColor(.blue)
                        }.padding(.horizontal)
                    }
                }
                
                DynamicIslandExpandedRegion(.center) {
                    Text(context.state.activity.location)
                        .font(.subheadline)
                        .fontWeight(.bold)
                }
                
                DynamicIslandExpandedRegion(.trailing) {
                    if (context.state.activity.nature != "Scanning for Activity" && context.state.activity.nature != "Scanning Ended") {
                        VStack {
                            Text(context.state.activity.date ?? Date(), style: .relative)
                                .multilineTextAlignment(.center)
                                .monospacedDigit()
                            .font(.subheadline)
                            
                            Image(systemName: "clock.arrow.circlepath")
                                .foregroundColor(.orange)
                        }
                        .padding(.horizontal)
                    }
                }
                
                DynamicIslandExpandedRegion(.bottom) {
                    if (context.state.activity.nature != "Scanning for Activity" && context.state.activity.nature != "Scanning Ended") {
                        VStack {
                            Text(context.state.activity.nature)
                            .font(.title2)
                                .multilineTextAlignment(.center)
                                .padding(.top)
                                .fontWeight(.bold)
                            
                            Text(context.state.activity.address)
                        }
                        .font(.caption)
                        .padding(.top, -10)
                    } else {
                        Text(context.state.activity.nature)
                            .font(.title)
                            .padding(.top)
                    }
                }
        
            } compactLeading: {
                Label {
                    Text("Scanning")
                } icon: {
                    Image("DI_Icon")
                }
                .font(.caption)
                
            } compactTrailing: {
                if (context.state.activity.id != 0) {
                    Text(context.state.activity.date ?? Date(), style: .relative)
                        .font(.system(size: 10))
                        .frame(width: 40)
                } else {
                    Image(systemName: "magnifyingglass")
                        .frame(width: 20)
                }
                    
            } minimal: {
                if (context.state.activity.id != 0) {
                    Image(systemName: "exclamationmark.triangle")
                        .foregroundColor(.red)
                        .frame(width: 20)
                } else {
                    Image(systemName: "magnifyingglass")
                        .frame(width: 20)
                }
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.blue)
        }
    }
}

struct WidgetExtension_Preview: PreviewProvider {
    static var previews: some View {
        let testState = LatestAttribute.ContentState(activity: Scanner.Activity(id: 1116, timestamp: "06/07/1998 - 01:01:01", nature: "Scanning for Activity", address: "5522 Old Dover Blvd", location: "Canterbury Green", controlNumber: "10AD43", longitude: -85.10719687273503, latitude: 41.13135945131842, distance: 10))
        
        LockScreenView(state: testState)
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
