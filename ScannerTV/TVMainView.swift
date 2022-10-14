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
    @ObservedObject var viewModel : ScannerActivityListViewModel
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
                    TVMapView(viewModel: viewModel)
                } else {
                    HStack {
                        VStack {
                            if (viewModel.isLoading || !viewModel.serverResponsive) {
                                TVStatusView(viewModel: viewModel)
                                    .frame(width: 450)
                                    .onTapGesture {
                                        if (!viewModel.serverResponsive) {
                                            withAnimation (.linear(duration: 0.5)) {
                                                viewModel.serverResponsive = true
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                                    viewModel.serverResponsive = false
                                                    viewModel.refresh()
                                                }
                                            }
                                        }
                                    }
                            } else {
                                Section {
                                    List(viewModel.activities) { activity in
                                        TVRowView(activity: activity, chosenActivity: $chosenActivity)
                                        
                                        if (viewModel.activities.last == activity) {
                                            Section {
                                                ProgressView()
                                                    .frame(idealWidth: .infinity, maxWidth: .infinity, alignment: .center)
                                                    .onAppear {
                                                        if (!viewModel.needScroll){
                                                            viewModel.getMoreActivities()
                                                        }
                                                    }
                                                    .onDisappear {
                                                        viewModel.needScroll = false
                                                    }
                                            }
                                        }
                                    }
                                }.refreshable {
                                    withAnimation {
                                        viewModel.refresh()
                                    }
                                }.frame(width: 450)
                            }
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
                    }.padding(.trailing)
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
