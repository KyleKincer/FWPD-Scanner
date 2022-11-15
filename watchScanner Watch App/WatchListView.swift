
//
//  WatchListView.swift
//  watchScanner Watch App
//
//  Created by Nick Molargik on 9/30/22.
//

import SwiftUI

struct WatchListView: View {
    @ObservedObject var viewModel: MainViewModelWatch
    @State var showMap = false
    @State var showSettings = false
    var watch = WKInterfaceDevice()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                VStack {
                    if (viewModel.isRefreshing && !showMap) {
                        WatchStatusView(viewModel: viewModel)
                            .onTapGesture {
                                if (!viewModel.serverResponsive) {
                                    viewModel.serverResponsive = true
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                        viewModel.serverResponsive = false
                                        viewModel.refreshWatch()
                                    }
                                }
                            }
                            .frame(width: geometry.size.width)
                    } else {
                        if (showMap) {
                            WatchMapView(viewModel: viewModel)
                        } else {
                        NavigationView{
                            Section {
                                List(viewModel.activities) { activity in
                                    WatchRowView(activity: activity)
                                    
                                    if (activity == viewModel.activities.last) {
                                        Section {
                                            if (viewModel.isLoading) {
                                                ProgressView()
                                                    .frame(idealWidth: .infinity, maxWidth: .infinity, alignment: .center)
                                            } else {
                                                Text("Tap for More")
                                                    .bold()
                                                    .italic()
                                                    .foregroundColor(.blue)
                                                    .frame(idealWidth: .infinity, maxWidth: .infinity, alignment: .center)
                                                    .onTapGesture {
                                                        viewModel.getMoreActiviesWatch()
                                                        
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }.refreshable {
                                withAnimation {
                                    viewModel.refreshWatch()
                                }
                            }
                            .navigationBarTitleDisplayMode(.inline)
                        }
                    }
                    Spacer()
                    
                    HStack {
                        
                        ZStack {
                            Rectangle()
                                .frame(width: geometry.size.width / 2 - 10, height: 65)
                                .foregroundColor(.blue)
                                .cornerRadius(5)
                            Image(systemName: showMap ? "list.bullet.below.rectangle" : "map")
                                .foregroundColor(.white)
                                .padding(.bottom, 40)
                        }
                        .onTapGesture {
                            withAnimation {
                                showMap.toggle()
                                viewModel.playHaptic()
                            }
                        }
                        
                        ZStack {
                            Rectangle()
                                .frame(width: geometry.size.width / 2 - 10, height: 65)
                                .foregroundColor(viewModel.serverResponsive ? .orange : .gray)
                                .cornerRadius(5)
                            Image(systemName: "gear")
                                .foregroundColor(.white)
                                .padding(.bottom, 40)
                        }
                        .onTapGesture {
                            withAnimation {
                                showSettings.toggle()
                                viewModel.playHaptic()
                            }
                            
                        }
                        .onLongPressGesture {
                            withAnimation {
                                viewModel.refreshWatch()
                            }
                        }
                        .disabled(!viewModel.serverResponsive)
                    }
                    .padding(.bottom, -60)
                    .padding(.horizontal, 0)
                }
            }
            .sheet(isPresented: $showSettings, content: {
                WatchSettingsView(viewModel: viewModel)
            })
        }
    }
}

struct WatchListView_Previews: PreviewProvider {
    static var previews: some View {
        WatchListView(viewModel: MainViewModelWatch())
    }
}
