//
//  TopView.swift
//  WidgetExtensionExtension
//
//  Created by Nick Molargik on 10/1/22.
//

import SwiftUI

struct TopView: View {
    @State var state: LatestAttribute.ContentState
    
    var body: some View {
        HStack (alignment: .top) {
            VStack (alignment: .leading) {
                if (state.activity.nature == "Scanning for Activity" || state.activity.nature == "Scanning Ended") {
                    Text("Scanner")
                        .font(.system(size: 50))
                } else {
                    HStack {
                        Text("Latest: ")
                            .font(.system(size: 20))
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: false)
                        
                        Text(state.activity.nature)
                            .font(.system(size: 30))
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: false)
                            .padding(.trailing)
                    }
                }
                
                if (state.activity.nature != "Scanning for Activity" && state.activity.nature != "Scanning Ended") {
                    Text(state.activity.date ?? Date(), style: .relative)
                        .font(.system(size: 20))
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
        .padding([.top, .horizontal])
    }
}
