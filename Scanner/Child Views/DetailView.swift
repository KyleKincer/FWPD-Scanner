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
    @ObservedObject var viewModel : MainViewModel
    @Binding var activity : Scanner.Activity
    @AppStorage("showDistance") var showDistance = true
    @State private var isBookmarked = false
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Group { // header
                    Text(activity.nature)
                        .font(.largeTitle)
                        .italic()
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal)
                        .padding(.bottom, 5)
                    
                    if (sizeClass == .compact) {
                        Button (action: {
                            withAnimation {
                                if (activity.bookmarked) {
                                    activity.bookmarked = false
                                    isBookmarked = false
                                    viewModel.removeBookmark(bookmark: activity)
                                    if (viewModel.showBookmarks) {
                                        withAnimation {
                                            viewModel.activities.removeAll { $0.controlNumber == activity.controlNumber }
                                        }
                                    }
                                } else {
                                    activity.bookmarked = true
                                    isBookmarked = true
                                    viewModel.addBookmark(bookmark: activity)
                                    if (viewModel.showBookmarks) {
                                        withAnimation {
                                            viewModel.activities.append(activity)
                                        }
                                    }
                                }
                            }
                            
                        }, label: {
                            VStack {
                                Image(systemName: "bookmark.circle.fill")
                            }
                            .font(.system(size: 40))
                            .foregroundColor(isBookmarked ? .yellow : .gray)
                        })
                            .padding(.bottom, 5)
                    }
                    
                    
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
                    
                    Text("\(activity.date ?? Date(), style: .relative) ago")
                        .padding(.horizontal)
                        .padding(.bottom, 3)
                    
                    Label(title: {
                        Text(activity.address)}, icon: {
                            Image(systemName: "mappin.and.ellipse")
                            
                        })
                    .padding(.horizontal)
                    
                    if (showDistance) {
                        Text("\(String(format: "%g", round(10 * (activity.distance ?? 0)) / 10)) miles away")
                            .padding(.horizontal)
                            .padding(.bottom, 3)
                    }
                }
                
                DetailMapView(viewModel: viewModel, activity: activity)
                    .mask(LinearGradient(gradient: Gradient(colors: [.black, .black, .black, .clear]), startPoint: .bottom, endPoint: .top))
                    .edgesIgnoringSafeArea(.all)
                    .onAppear {
                        viewModel.region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: activity.latitude, longitude: activity.longitude), latitudinalMeters: 300, longitudinalMeters: 300)
                    }
                    .onDisappear {
                        viewModel.region = MKCoordinateRegion(center: Constants.defaultLocation, span: MKCoordinateSpan(latitudeDelta: 0.075, longitudeDelta: 0.075))
                    }
                
                
            }
            .padding(.top, 30)
            .navigationBarTitleDisplayMode(.inline)
            .transition(.slide)
            .onAppear {
                isBookmarked = activity.bookmarked
            }
            .onTapGesture(perform: {
                isBookmarked = activity.bookmarked
            })
        }
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView(viewModel: MainViewModel(), activity: .constant(Scanner.Activity(id: 1116, timestamp: "06/07/1998 - 01:01:01", nature: "Wild Kyle Appears", address: "5522 Old Dover Blvd", location: "Canterbury Green", controlNumber: "10AD43", longitude: -85.10719687273503, latitude: 41.13135945131842)))
    }
}

