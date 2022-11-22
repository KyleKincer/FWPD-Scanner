//
//  ActivityView.swift
//  Scanner
//
//  Created by Nick Molargik on 9/29/22
//

import SwiftUI
import MapKit

struct ActivityView: View {
    @Environment(\.horizontalSizeClass) var sizeClass
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject private var appDelegate: AppDelegate
    
    @Binding var showMap : Bool
    @State private var showFilter = false
    @State var status = 0
    @State var chosenActivity : Scanner.Activity?
    @ObservedObject var viewModel : MainViewModel
    
    var body: some View {
        ZStack {
            colorScheme == .light ? Color.white : Color.black // Background
            if (appDelegate.openedFromNotification) {
                ZStack {
                    DetailView(viewModel: viewModel, activity: $appDelegate.notificationActivity)
                        .environmentObject(appDelegate)
                        .onAppear {
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
                    
                    VStack {
                        HStack {
                            Button(action: {
                                withAnimation {
                                    appDelegate.openedFromNotification = false
                                }
                            }, label: {
                                Image(systemName: "chevron.left")
                                    .foregroundColor(.blue)
                                Text("Back")
                                    .foregroundColor(.blue)
                            })
                            
                            Spacer()
                        }
                        .padding()
                        
                        Spacer()
                    }
                }
                
            } else {
                // StatusView if necessary
                if (viewModel.isRefreshing || (!viewModel.showBookmarks && !viewModel.serverResponsive)) {
                    StatusView(viewModel: viewModel)
                        .onTapGesture {
                            withAnimation (.linear(duration: 0.5)) {
                                viewModel.serverResponsive = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                    viewModel.serverResponsive = false
                                    viewModel.refresh()
                                }
                            }
                        }
                    
                    // MapView if necessary
                } else if (showMap) {
                    MapView(chosenActivity: $chosenActivity, activities: (viewModel.showBookmarks ? $viewModel.bookmarks : $viewModel.activities), viewModel: viewModel)
                        .edgesIgnoringSafeArea(.all)
                    
                    // Show ListView
                } else {
                    if (sizeClass == .compact) {
                        if #available(iOS 16.0, *) {
                            NavigationStack {
                                ListView(viewModel: viewModel)
                            }
                            
                        } else {
                            ListView(viewModel: viewModel)
                        }
                    } else {
                        if #available(iOS 16.0, *) {
                            NavigationSplitView {
                                ListView(viewModel: viewModel)
                            }
                        detail: {
                            VStack {
                                Text("Select an event to view details")
                                    .padding(20)
                                    .fontWeight(.semibold)
                                
                                Image(systemName: "square.stack.3d.down.forward.fill")
                                    .scaleEffect(3)
                                    .padding(20)
                                
                            }.font(.system(size: 30))
                        }
                        .navigationSplitViewStyle(.balanced)
                        .navigationBarTitleDisplayMode(.inline)
                        } else {
                            ListView(viewModel: viewModel)
                        }
                    }
                }
            }
        }
    }
}


struct ActivityView_Previews: PreviewProvider {
    static var previews: some View {
        ActivityView(showMap: .constant(false), viewModel: MainViewModel())
    }
}
