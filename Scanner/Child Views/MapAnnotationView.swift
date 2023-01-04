//
//  MapAnnotationView.swift
//  Scanner
//
//  Created by Nick Molargik on 9/29/22.
//

import SwiftUI
import MapKit

struct MapAnnotationView: View {
    @State private var showDetails = false
    @State var activity : Scanner.Activity
    @Binding var chosenActivity : Scanner.Activity?
    
    var body: some View {
        
        Button (action : {
            withAnimation {
                if (chosenActivity == activity) {
                    chosenActivity = nil
                } else {
                    chosenActivity = activity
                }
            }
        }, label: {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(chosenActivity == activity ? .blue : .red)
                .scaleEffect(chosenActivity == activity ? 2 : 1)
        })
    }
}

struct MapAnnotationView_Previews: PreviewProvider {
    static var previews: some View {
        MapAnnotationView(activity: Scanner.Activity(id: "1116", timestamp: "06/07/1998 - 01:01:01", nature: "Wild Kyle Appears", address: "5522 Old Dover Blvd", location: "Canterbury Green", controlNumber: "10AD43", longitude: -85.10719687273503, latitude: 41.13135945131842, commentCount: 2), chosenActivity: .constant(nil))
            .frame(width: 30, height: 30)
    }
}
