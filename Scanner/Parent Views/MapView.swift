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
        ZStack(alignment: .topTrailing) {
            Map(coordinateRegion: $mapModel.region, showsUserLocation: true, annotationItems: activities) { activity in
                MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: activity.latitude, longitude: activity.longitude)) {
                    MapAnnotationView(activity: activity, chosenActivity: $chosenActivity)
                        .onTapGesture {
                            mapModel.region.center.latitude = activity.latitude
                            mapModel.region.center.longitude = activity.longitude
                            
                        }
                }
            }
            .mask(LinearGradient(gradient: Gradient(colors: [.black, .black, .black, .clear]), startPoint: .bottom, endPoint: .top))
            .edgesIgnoringSafeArea(.all)
            .onDisappear {
                chosenActivity = nil
            }
            
            if (chosenActivity != nil) {
                Group {                
                    VStack {
                        HStack {
                            
                            Spacer()
                            
                            Text(chosenActivity!.nature)
                                .italic()
                                .bold()
                                .padding(.trailing, -8)
                                .lineLimit(1)
                                .font(.system(size: 20))
                            
                            Spacer()
                            
                        }.padding(.top)
                        
                        HStack {
                            
                            Spacer()
                            
                            Text(chosenActivity!.address)
                                .padding(.trailing, -8)
                                .lineLimit(1)
                                .font(.system(size: 15))
                            
                            if chosenActivity!.distance != nil {
                                Text(", \(String(format: "%g", round(10 * chosenActivity!.distance!) / 10)) mi away")
                                    .padding(.trailing, -8)
                                    .lineLimit(1)
                                    .font(.system(size: 15))
                            }
                            
                            Spacer()
                        }
                        .font(.system(size: 10))
                        
                        HStack {
                            
                            Spacer()
                            Text("\(chosenActivity!.timestamp) (")
                                .padding(.trailing, -8.5)
                            Text(chosenActivity!.date ?? Date(), style: .relative)
                                .padding(.trailing, -3)
                            Text("ago)")
                            Spacer()
                        }.padding(.bottom)
                        
                        Spacer()
                    }
                    .shadow(radius: 10)
                }
            }
            VStack {
                Spacer()
                
                HStack {
                    
                    Spacer()
                    
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
                                
                                if (viewModel.isLoading) {
                                    ProgressView()
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
                        .frame(width: viewModel.isLoading ? 50 : 120, height: 33)
                        .padding(.bottom, 30)
                    }
                    
                    Spacer()
                
                }.transition(.move(edge: .top))
            }
        }
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView(chosenActivity: .constant(nil), activities: .constant([]), viewModel: MainViewModel())
    }
}
