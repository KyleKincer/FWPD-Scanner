
//
//  WatchListView.swift
//  watchScanner Watch App
//
//  Created by Nick Molargik on 9/30/22.
//

import SwiftUI

struct WatchListView: View {
    @ObservedObject var viewModel: ScannerActivityListViewModel
    @State var showMap = false
    @State var showSettings = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                VStack {
                    if (viewModel.isLoading) {
                        WatchStatusView(viewModel: viewModel)
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
                            .frame(width: geometry.size.width)
                    } else {
                        if (showMap) {
                            WatchMapView(viewModel: viewModel)
                        } else {
                        NavigationView{
                            List(viewModel.activities) { activity in
                                WatchRowView(activity: activity)
                                    .onAppear {
                                        viewModel.getMoreActivitiesIfNeeded(currentActivity: activity)
                                    }
                                }
                                
                            }.refreshable {
                                withAnimation {
                                    viewModel.refresh()
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
                            }
                        }
                        
                        ZStack {
                            Rectangle()
                                .frame(width: geometry.size.width / 2 - 10, height: 65)
                                .foregroundColor(.orange)
                                .cornerRadius(5)
                            Image(systemName: "gear")
                                .foregroundColor(.white)
                                .padding(.bottom, 40)
                        }
                        .onTapGesture {
                            withAnimation {
                                showSettings.toggle()
                            }
                            
                        }
                        .onLongPressGesture {
                            withAnimation {
                                viewModel.refresh()
                            }
                            
                        }
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
        WatchListView(viewModel: ScannerActivityListViewModel())
    }
}
