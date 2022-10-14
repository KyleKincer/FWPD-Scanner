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
    @ObservedObject var viewModel: ScannerActivityListViewModel
    @Environment(\.colorScheme) var colorScheme
    let deviceIdiom = UIScreen.main.traitCollection.userInterfaceIdiom
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Map(coordinateRegion: $mapModel.region, showsUserLocation: true, annotationItems: viewModel.activities) { activity in
                MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: activity.latitude, longitude: activity.longitude)) {
                    MapAnnotationView(viewModel: viewModel, activity: activity, chosenActivity: $chosenActivity)
                }
            }
            .mask(LinearGradient(gradient: Gradient(colors: [.black, .black, .black, .clear]), startPoint: .bottom, endPoint: .top))
            
            if (chosenActivity?.id ?? 0 > 0) {
                VStack (alignment: .center) {
                    Spacer()
            
                    HStack {
                        
                        Spacer()
                        
                        ZStack {
                            
                            Rectangle()
                                .foregroundColor(colorScheme == .light ? .white : .black)
                                .frame(width: 500, height: 100)
                                .cornerRadius(20)
                            
                            VStack {
                                HStack {
                                    Text(chosenActivity!.nature)
                                        .padding(.trailing, -8)
                                        .lineLimit(1)
                                        .font(.system(size: 20))
                                }
                                HStack {
                                    Text(chosenActivity!.address)
                                        .padding(.trailing, -8)
                                        .lineLimit(1)
                                        .font(.system(size: 15))
                                    
                                    if chosenActivity!.distance != nil {
                                        Text(", \(String(format: "%g", round(10 * chosenActivity!.distance!) / 10)) mi away")
                                    }
                                }
                                .font(.system(size: 10))
                                
                                HStack {
                                    Text("\(chosenActivity!.timestamp) (")
                                        .padding(.trailing, -8.5)
                                    Text(chosenActivity!.date ?? Date(), style: .relative)
                                        .padding(.trailing, -3)
                                    Text("ago)")
                                }
                            }
                        }
                    }
                }
                .transition(.opacity)
                .offset(y: 5)
            }
        }
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView(chosenActivity: .constant(nil), viewModel: ScannerActivityListViewModel())
    }
}
