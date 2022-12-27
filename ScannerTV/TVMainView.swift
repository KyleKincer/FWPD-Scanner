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
    @ObservedObject var viewModel : MainViewModel
    @State var mapView = MapViewModel()
    @State var chosenActivity = Scanner.Activity(id: "0", timestamp: "", nature: "", address: "Select an Activity to View Details", location: "", controlNumber: "", longitude: 0, latitude: 0)
    @State var getMoreFocus : FocusState = FocusState()
    
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
                            if (viewModel.isRefreshing || !viewModel.serverResponsive) {
                                TVStatusView(viewModel: viewModel)
                                    .frame(width: 450)
                                    .onLongPressGesture(minimumDuration: 0.01) {
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
                                
                                Spacer()

                            } else {
                                Section {
                                    List(viewModel.activities) { activity in
                                        TVRowView(activity: activity, chosenActivity: $chosenActivity)
                                        
                                        if (activity == viewModel.activities.last) {
                                            Section {
                                                if (viewModel.isLoading) {
                                                    ProgressView()
                                                        .frame(idealWidth: .infinity, maxWidth: .infinity, alignment: .center)
                                                } else {
                                                    Button(action: {
                                                        viewModel.getMoreActivities()
                                                    }, label: {
                                                        ZStack {
                                                            Rectangle()
                                                                .frame(width: 300, height: 100)
                                                                .foregroundColor(.white)
                                                                .cornerRadius(10)
                                                            
                                                            Text("Tap for More")
                                                                .bold()
                                                                .frame(idealWidth: .infinity, maxWidth: .infinity, alignment: .center)
                                                                .foregroundColor(.blue)
                                                        }
                                                    })
                                                    .padding()
                                                    .focusable()
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
                        
                        if (chosenActivity.id == "0") {
                            
                            VStack (alignment: .center){
                                Text("Select an Activity to see Details")
                                    .font(.title)
                                    .padding(.horizontal)
                                
                                Image(systemName: "magnifyingglass")
                                    .font(.system(size: 100))
                                    .foregroundColor(Color("ModeOpposite"))
                                    .padding()
                            }
                            
                            Spacer()
                            
                        } else {
                            
                            TVActivityDetailView(activity: chosenActivity)
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showLocationDisclaimer, content: {
            DisclaimerView()
        })
    }
}

struct TVMainView_Previews: PreviewProvider {
    static var previews: some View {
        TVMainView(viewModel: MainViewModel())
    }
}
