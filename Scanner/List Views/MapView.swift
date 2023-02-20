//
//  MapView.swift
//  Scanner
//
//  Created by Kyle Kincer on 1/19/22.
//

import SwiftUI
import MapKit

struct MapView: View {
    @State var mapModel = MapViewModel()
    @Binding var chosenActivity : Scanner.Activity?
    @Binding var activities : [Scanner.Activity]
    @ObservedObject var viewModel: MainViewModel
    @Environment(\.colorScheme) var colorScheme
    let deviceIdiom = UIScreen.main.traitCollection.userInterfaceIdiom
    
    var body: some View {
        ZStack() {
            if (viewModel.isRefreshing) {
                Text("Refreshing...")
                    .font(.title2)
                    .fontWeight(.bold)
            } else {
                if (viewModel.activities.count > 0) {
                    Map(coordinateRegion: $mapModel.region, showsUserLocation: true, annotationItems: (viewModel.showBookmarks) ? viewModel.bookmarks : viewModel.activities) { activity in
                        MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: activity.latitude, longitude: activity.longitude)) {
                            Button (action : {
                                withAnimation {
                                    if (chosenActivity == activity) {
                                        chosenActivity = nil
                                    } else {
                                        chosenActivity = nil
                                        chosenActivity = activity
                                    }
                                }
                            }, label: {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(chosenActivity == activity ? .blue : .red)
                                    .font(.system(size: chosenActivity == activity ? 50 : 20))
                            })
                        }
                    }
                    .mask(LinearGradient(gradient: Gradient(colors: [.black, .black, .black, .clear]), startPoint: .bottom, endPoint: .top))
                    .edgesIgnoringSafeArea(.all)
                    .onDisappear {
                        withAnimation {
                            chosenActivity = nil
                        }
                    }
                } else {
                    Map(coordinateRegion: $mapModel.region, showsUserLocation: true)
                        .mask(LinearGradient(gradient: Gradient(colors: [.black, .black, .black, .clear]), startPoint: .bottom, endPoint: .top))
                        .edgesIgnoringSafeArea(.all)
                        .onDisappear {
                            chosenActivity = nil
                        }
                }
            }
            
            VStack {
                Text("Only FWPD Activity is shown on the Map")
                    .foregroundColor(Color("ModeOpposite"))
                    .italic()
                
                Spacer()
                
                HStack {
                    if (!viewModel.showBookmarks) {
                        Button() {
                            playHaptic()
                            if (!viewModel.isLoading) {
                                withAnimation {
                                    viewModel.getMoreActivities()
                                    viewModel.addDatesToActivities(.activities)
                                    viewModel.addDistancesToActivities(.activities)
                                }
                            }
                            
                        } label: {
                            ZStack{
                                RoundedRectangle(cornerRadius: 15)
                                    .foregroundColor(.blue)
                                    .shadow(radius: 10)
                                
                                if (viewModel.isLoading) {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    HStack {
                                        Text("Get More")
                                            .fontWeight(.semibold)
                                        
                                        Image(systemName: "goforward.plus")
                                    }
                                    .tint(.white)
                                }
                            }
                        }
                        .frame(width: 140, height: 35)
                        .onLongPressGesture(perform: {
                            withAnimation {
                                playHaptic()
                                viewModel.refreshActivities()
                            }
                        })
                    }
                    
                    if (viewModel.loggedIn) {
                        Button(action: {
                            withAnimation {
                                playHaptic()
                                viewModel.showBookmarks.toggle()
                            }
                        }, label: {
                            ZStack{
                                RoundedRectangle(cornerRadius: 15)
                                    .foregroundColor(.blue)
                                    .shadow(radius: 10)
                                
                                HStack {
                                    if (viewModel.showBookmarks) {
                                        Image(systemName: "bookmark.fill")
                                            .foregroundColor(.orange)
                                        
                                        Text("Disable")
                                            .fontWeight(.semibold)
                                            .foregroundColor(.white)
                                        
                                    } else {
                                        Image(systemName: "bookmark")
                                            .foregroundColor(.orange)
                                            .tint(.white)
                                        
                                        Text("Bookmarks")
                                            .fontWeight(.semibold)
                                            .foregroundColor(.white)
                                    }
                                }
                                .padding(.horizontal, 2)
                            }
                            .frame(width: 140, height: 35)
                        })
                    }
                }
                .padding(.horizontal)
                .padding(.bottom)
                
                if (chosenActivity != nil) {
                    Group { // header
                        VStack {
                            Text(chosenActivity!.nature == "" ? "Unknown" : chosenActivity!.nature)
                                .font(.system(size: 30))
                                .italic()
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)
                                .padding([.top, .leading, .trailing])
                                .padding(.bottom, 5)
                            
                            HStack {
                                VStack(alignment: .leading, spacing: 5) {
                                    HStack(spacing: 5) {
                                        Text(chosenActivity!.timestamp)
                                    }
                                    .foregroundColor(.secondary)
                                    
                                    Text("\(chosenActivity?.date ?? Date(), style: .relative) ago")
                                        .foregroundColor(.secondary)
                                }
                                .padding(.leading)
                                
                                Spacer()
                                
                                HStack {
                                    VStack(alignment: .trailing, spacing: 5) {
                                        HStack(spacing: 5) {
                                            Text(chosenActivity!.address)
                                                .foregroundColor(.secondary)
                                            Image(systemName: "mappin.and.ellipse")
                                                .foregroundColor(.secondary)
                                        }
                                        
                                        Text("ID: \(chosenActivity!.controlNumber)")
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .padding(.trailing)
                            }
                            .padding(.bottom)
                            .padding(.horizontal)
                        }
                    }
                    .font(.footnote)
                    .background(Color(.secondarySystemBackground)
                        .opacity(0.9))
                    .cornerRadius(30)
                    .shadow(radius: 8)
                    .padding(.horizontal, 5)
                    .padding(.bottom, 20)
                    .transition(.move(edge: .bottom))
                    .onTapGesture {
                        withAnimation {
                            chosenActivity = nil
                        }
                    }
                    .frame(maxWidth: 500)
                }
            }
        }
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView(chosenActivity: .constant(Scanner.Activity(id: "", timestamp: "right now", nature: "Wild Kyle Appears", address: "1105 Normandale Dr", location: "Chuck E Cheese", controlNumber: "5ABC123", longitude: 10.0, latitude: 10.0, commentCount: 2)), activities: .constant([]), viewModel: MainViewModel())
    }
}
