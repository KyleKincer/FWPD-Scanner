//
//  DetailMapView.swift
//  Scanner
//
//  Created by Nick Molargik on 10/16/22.
//

import SwiftUI
import MapKit

struct DetailMapView: View {
    @State var viewModel: MainViewModel
    @EnvironmentObject private var appDelegate: AppDelegate
    @Binding var activity : Scanner.Activity
    @State var manager = CLLocationManager()
    @StateObject var managerDelegate = locationDelegate()
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Map(coordinateRegion: $managerDelegate.region, interactionModes: .all, showsUserLocation: true, userTrackingMode: .none, annotationItems: [activity]) { activity in
                MapMarker(coordinate: CLLocationCoordinate2D(latitude: activity.latitude, longitude: activity.longitude), tint: .accentColor)
            }
            .onAppear {
                manager.delegate = managerDelegate
                managerDelegate.region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: activity.latitude, longitude: activity.longitude), span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
            }
            
            Button() {
                playHaptic()
                let url = URL(string: "maps://?saddr=&daddr=\(activity.latitude),\(activity.longitude)")
                if UIApplication.shared.canOpenURL(url!) {
                    UIApplication.shared.open(url!, options: [:], completionHandler: nil)
                }
            } label: {
                ZStack{
                    RoundedRectangle(cornerRadius: 15)
                    HStack {
                        Text("Open in Maps").fontWeight(.semibold)
                        Image(systemName: "arrowshape.turn.up.right")
                        
                    }
                    .tint(.white)
                }.frame(width: 200, height: 45)
                    .padding(.bottom)
            }
            
            if (viewModel.loggedIn) {
                HStack {
                    
                    Spacer()
                    
                    Button(action: {
                        playHaptic()
                        activity.bookmarked.toggle()
                        
                        if (activity.bookmarked) {
                            viewModel.addBookmark(bookmark: activity)
                            if (viewModel.showBookmarks) {
                                withAnimation {
                                    viewModel.activities.append(activity)
                                }
                            }
                            
                        } else {
                            viewModel.removeBookmark(bookmark: activity)
                            if (viewModel.showBookmarks) {
                                withAnimation {
                                    viewModel.activities.removeAll { $0.controlNumber == activity.controlNumber }
                                }
                            }
                        }
                        
                    }, label: {
                        ZStack {
                            Circle()
                                .frame(width: 45, height: 45)
                                .foregroundColor(.blue)
                            
                            Image(systemName: activity.bookmarked ? "bookmark.fill" : "bookmark")
                                .foregroundColor(activity.bookmarked ? .orange : .white)
                        }
                    })
                    .padding(.bottom)
                    .padding(.trailing)
                }
                .onChange(of: appDelegate.notificationActivity.latitude, perform: { _ in
                    managerDelegate.region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: appDelegate.notificationActivity.latitude, longitude: appDelegate.notificationActivity.longitude), span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
                })
                
            }
            
        }
    }
}

class locationDelegate: NSObject,ObservableObject,CLLocationManagerDelegate{
    // From here and down is new
    @Published var location: CLLocation?

    @State var hasSetRegion = false

    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 38.898150, longitude: -77.034340),
        span: MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1)
    )

    // Checking authorization status...

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {

        if manager.authorizationStatus == .authorizedWhenInUse{
            print("G - Location Authorized")
            manager.startUpdatingLocation()
        } else {
            print("X - Location Not Authorized")
            manager.requestWhenInUseAuthorization()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // pins.append(Pin(location:locations.last!))

        // From here and down is new

    }
}

//struct DetailMapView_Previews: PreviewProvider {
//    static var previews: some View {
//        DetailMapView(viewModel: MainViewModel(), activity: .constant(Scanner.Activity(id: "1116", timestamp: "06/07/1998 - 01:01:01", nature: "Wild Kyle Appears", address: "5522 Old Dover Blvd", location: "Canterbury Green", controlNumber: "10AD43", longitude: -85.10719687273503, latitude: 41.13135945131842)))
//    }
//}
