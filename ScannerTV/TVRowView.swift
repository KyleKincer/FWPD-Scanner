//
//  TVRowView.swift
//  ScannerTV
//
//  Created by Nick Molargik on 10/12/22.
//

import SwiftUI

struct TVRowView: View {
    let activity: Scanner.Activity
    @FocusState private var focused : Bool
    @Environment(\.colorScheme) var colorScheme
    @Binding var chosenActivity : Scanner.Activity
    
    var body: some View {
        NavigationLink(destination: {TVActivityDetailView(activity: activity)}) {
            ZStack {
                if (focused) {
                    Color.blue
                        .edgesIgnoringSafeArea(.all)
                        .cornerRadius(10)
                } else {
                    if (colorScheme == .light) {
                        Color.white
                            .edgesIgnoringSafeArea(.all)
                    } else {
                        Color.black
                            .edgesIgnoringSafeArea(.all)
                    }
                }
                
                VStack(spacing: 5) {
                    HStack {
                        Text(activity.nature == "" ? "Unknown" : activity.nature)
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
                        
                        Image(systemName: "chevron.right")
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
                }.padding(.horizontal)
                
            }.frame(width: 500, height: 200)
        }
        .focusable()
        .focused($focused)
        .onLongPressGesture(minimumDuration: 0.01) {
            chosenActivity = activity
        }
    }
}

struct TVRowView_Previews: PreviewProvider {
    static var previews: some View {
        TVRowView(activity: Scanner.Activity(id: "1116", timestamp: "06/07/1998 - 01:01:01", nature: "Wild Kyle Appears", address: "5522 Old Dover Blvd", location: "Canterbury Green", controlNumber: "10AD43", longitude: -85.10719687273503, latitude: 41.13135945131842), chosenActivity: .constant(Scanner.Activity(id: "1116", timestamp: "06/07/1998 - 01:01:01", nature: "Wild Kyle Appears", address: "5522 Old Dover Blvd", location: "Canterbury Green", controlNumber: "10AD43", longitude: -85.10719687273503, latitude: 41.13135945131842)))
    }
}
