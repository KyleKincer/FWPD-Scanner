//
//  TVMain.swift
//  ScannerTV
//
//  Created by Nick Molargik on 10/12/22.
//

import SwiftUI

struct TVMainView: View {
    @Environment(\.colorScheme) var colorScheme
    @State var showMap = false
    @State var showLocationDisclaimer = false
    @State var viewModel : ScannerActivityListViewModel
    @State var mapView = MapViewModel()
    @State var chosenActivity = Scanner.Activity(id: 0, timestamp: "", nature: "", address: "Select an Activity to View Details", location: "", controlNumber: "", longitude: 0, latitude: 0)
    
    var body: some View {
        ZStack {
            if (colorScheme == .light) {
                Color.white
                    .edgesIgnoringSafeArea(.all)
            } else {
                Color.black
                    .edgesIgnoringSafeArea(.all)
            }
            
            VStack {
                TVNavBarView(showMap: $showMap, showLocationDisclaimer: $showLocationDisclaimer, viewModel: viewModel)
                
                if (showMap) {
                    TVMapView(viewModel: $mapView, listViewModel: $viewModel)
                } else {
                    HStack {
                        VStack {
                            List(viewModel.activities) {
                                if viewModel.isLoading {
                                    if $0 == viewModel.activities.first {
                                        HStack {
                                            Spacer()
                                            
                                            ProgressView()
                                                .progressViewStyle(CircularProgressViewStyle())
                                            
                                            Spacer()
                                        }
                                    }
                                } else {
                                    TVRowView(activity: $0, chosenActivity: $chosenActivity)
                                }
                            }.frame(width: 450)
                        }
                        
                        Spacer()
                        
                        if (chosenActivity.id == 0) {
                            
                            VStack (alignment: .center){
                                Spacer()
                                
                                Text("Select an Activity to see Details")
                                    .font(.title)
                                    .padding(.horizontal)
                                
                                Image(systemName: "magnifyingglass")
                                    .font(.system(size: 100))
                                    .foregroundColor(Color("ModeOpposite"))
                                    .padding()
                                
                                Spacer()
                            }
                            
                        } else {
                            
                            TVActivityDetailView(activity: chosenActivity)
                                .padding()
                            
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showLocationDisclaimer, content: {
            LocationDisclaimerView()
        })
    }
}

struct TVMainView_Previews: PreviewProvider {
    static var previews: some View {
        TVMainView(viewModel: ScannerActivityListViewModel())
    }
}
