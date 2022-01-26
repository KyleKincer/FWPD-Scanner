//
//  MapViewModel.swift
//  Scanner
//
//  Created by Kyle Kincer on 1/19/22.
//

import SwiftUI
import MapKit

final class MapViewModel: ObservableObject {
    @Published var region = MKCoordinateRegion(center: Constants.defaultLocation,
                                               span: MKCoordinateSpan(
                                                latitudeDelta: 0.075,
                                                longitudeDelta: 0.075))
    
}
