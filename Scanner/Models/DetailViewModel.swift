//
//  ScannerActivityDetailViewModel.swift
//  Scanner
//
//  Created by Kyle Kincer on 1/16/22.
//

import MapKit
import SwiftUI

final class ScannerActivityDetailViewModel: ObservableObject {
    @Published var region = MKCoordinateRegion()
    @Published var activityCoordinates: CLLocationCoordinate2D
    @Published var userTrackingMode: MapUserTrackingMode = .follow
    private let activity: Scanner.Activity
    
    init(activity: Scanner.Activity) {
        self.activity = activity
        self.activityCoordinates = CLLocationCoordinate2D(latitude: activity.latitude, longitude: activity.longitude)
        self.region = MKCoordinateRegion(center: activityCoordinates,
                                         span: Constants.defaultSpan)
    }
}
