//
//  DetailView.swift
//  Scanner
//
//  Created by Kyle Kincer on 1/13/22.
//

import SwiftUI
import MapKit
import CoreLocation
import CoreData

struct DetailView: View {
    @Environment(\.horizontalSizeClass) var sizeClass
    @EnvironmentObject private var appDelegate: AppDelegate
    @ObservedObject var viewModel : MainViewModel
    @Binding var activity : Scanner.Activity
    @AppStorage("showDistance") var showDistance = true
    @State private var isBookmarked = false
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                Group { // header
                    Text(activity.nature == "" ? "Unknown" : activity.nature)
                        .font(.system(size: 30))
                        .italic()
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal)
                    
                    HStack {
                            VStack(alignment: .leading, spacing: 5) {
                                HStack(spacing: 5) {
                                    Text(activity.timestamp)
                                }
                                .foregroundColor(.secondary)
                            
                            if (!viewModel.showBookmarks) {
                                Text("\(activity.date ?? Date(), style: .relative) ago")
                                    .foregroundColor(.secondary)
                            }
                            Text(activity.controlNumber)
                                .foregroundColor(.secondary)
                        }
                        .padding(.leading)
                        .padding(.vertical, 5)
                        
                        Spacer()
                        
                        HStack {
                            VStack(alignment: .trailing, spacing: 5) {
                                HStack(spacing: 5) {
                                    Text(activity.address)
                                        .foregroundColor(.secondary)
                                    Image(systemName: "mappin.and.ellipse")
                                        .foregroundColor(.secondary)
                                }
                                if (showDistance && !viewModel.showBookmarks) {
                                    Text("\(String(format: "%g", round(10 * (activity.distance ?? 0)) / 10)) miles away")
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .padding(.trailing)
                        .padding(.vertical, 5)
                    }
                    .font(.footnote)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)
                    .shadow(radius: 4)
                    .padding(.horizontal, 5)
                    .padding(.bottom, 5)
                    
                    
                    DetailMapView(viewModel: viewModel, activity: $activity)
                        .mask(LinearGradient(gradient: Gradient(colors: [.black, .black, .black, .clear]), startPoint: .bottom, endPoint: .top))
                        .frame(height: geometry.size.height * 0.4)
                        .edgesIgnoringSafeArea(.all)
                        .onAppear {
                            viewModel.region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: activity.latitude, longitude: activity.longitude), latitudinalMeters: 300, longitudinalMeters: 300)
                        }
                        .onDisappear {
                            viewModel.region = MKCoordinateRegion(center: Constants.defaultLocation, span: MKCoordinateSpan(latitudeDelta: 0.0375, longitudeDelta: 0.0375))
                        }
                        .environmentObject(appDelegate)
                        .cornerRadius(5.0)
                        .padding(.horizontal)
                    
                    CommentsView(viewModel: viewModel, activity: $activity)
                }
                .navigationBarTitleDisplayMode(.inline)
                .transition(.slide)
                .onAppear {
                    isBookmarked = activity.bookmarked
                    
                    let index = viewModel.history.firstIndex(of: activity)
                    
                    if (index != nil) {
                        viewModel.history.remove(at: index ?? 0)
                    }
                    viewModel.history.append(activity)
                    
                    
                }
            }
        }
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView(viewModel: MainViewModel(), activity: .constant(Scanner.Activity(id: "1116", timestamp: "06/07/1998 - 01:01:01", nature: "Wild Kyle Appears", address: "5522 Old Dover Blvd", location: "Canterbury Green", controlNumber: "10AD43", longitude: -85.10719687273503, latitude: 41.13135945131842, commentCount: 4)))
    }
}

