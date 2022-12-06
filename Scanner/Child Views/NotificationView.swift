//
//  NotificationView.swift
//  Scanner
//
//  Created by Nick Molargik on 11/22/22.
//

import SwiftUI
import MapKit
import CoreLocation
import CoreData

struct NotificationView: View {
    @Environment(\.horizontalSizeClass) var sizeClass
    @EnvironmentObject private var appDelegate: AppDelegate
    @ObservedObject var viewModel : MainViewModel
    @Binding var activity : Scanner.Activity
    @AppStorage("showDistance") var showDistance = true
    @State private var isBookmarked = false
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Group { // header
                    Text(activity.nature == "" ? "Unknown" : activity.nature)
                        .font(.largeTitle)
                        .italic()
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal)
                        .padding(.bottom, 5)
                    
                    Label(title: {
                        Text(activity.controlNumber)}, icon: {
                            Image(systemName: "info.circle")
                        })
                    .padding(.horizontal)
                    .padding(.bottom, 3)
                    
                    Label(title: {
                        Text("\(activity.timestamp)").padding(.trailing, -8.5)}, icon: {
                            Image(systemName: "clock")
                        })
                    
                    if (!viewModel.showBookmarks) {
                        Text("\(activity.date ?? Date(), style: .relative) ago")
                            .padding(.horizontal)
                            .padding(.bottom, 3)
                    }
                    
                    Label(title: {
                        Text(activity.address)}, icon: {
                            Image(systemName: "mappin.and.ellipse")
                            
                        })
                    .padding(.horizontal)
                    
                    if (showDistance && !viewModel.showBookmarks) {
                        Text("\(String(format: "%g", round(10 * (activity.distance ?? 0)) / 10)) miles away")
                            .padding(.horizontal)
                            .padding(.bottom, 3)
                    }
                }
                
                DetailMapView(viewModel: viewModel, activity: $activity)
                    .mask(LinearGradient(gradient: Gradient(colors: [.black, .black, .black, .clear]), startPoint: .bottom, endPoint: .top))
                    .edgesIgnoringSafeArea(.all)
                    .onAppear {
                        viewModel.region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: activity.latitude, longitude: activity.longitude), latitudinalMeters: 300, longitudinalMeters: 300)
                    }
                    .onDisappear {
                        viewModel.region = MKCoordinateRegion(center: Constants.defaultLocation, span: MKCoordinateSpan(latitudeDelta: 0.075, longitudeDelta: 0.075))
                    }
                    .environmentObject(appDelegate)
            }
            .padding(.top, 30)
            .navigationBarTitleDisplayMode(.inline)
            .transition(.slide)
            .onAppear{
                isBookmarked = activity.bookmarked
                Task.init {
                    do {
                        appDelegate.notificationActivity = try await viewModel.networkManager.getActivity(controlNumber: appDelegate.notificationActivity.controlNumber)
                        
                        let formatter = DateFormatter()
                        formatter.dateFormat = "yyyy/MM/dd HH:mm:SS"
                    appDelegate.notificationActivity.date = formatter.date(from: appDelegate.notificationActivity.timestamp)


                        if let location = viewModel.locationManager.location {
                            appDelegate.notificationActivity.distance = ((location.distance(from: CLLocation(latitude: appDelegate.notificationActivity.latitude, longitude: appDelegate.notificationActivity.longitude))) * 0.000621371)
                        }
                    }
                }
                print("G - Opened from notification")
            }
            .onDisappear {
                viewModel.refresh()
            }
        }
    }
}

struct NotificationView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationView(viewModel: MainViewModel(), activity: .constant(Scanner.Activity()))
    }
}
