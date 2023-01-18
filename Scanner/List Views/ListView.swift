//
//  ListView.swift
//  Scanner
//
//  Created by Kyle Kincer on 1/11/22.
//

import SwiftUI

struct ListView: View {
    @Environment(\.scenePhase) var scenePhase
    @ObservedObject var viewModel: MainViewModel
    @State var showingRefreshReminder = false
    @State var showRefreshReminderOnActive = false
    @Environment(\.horizontalSizeClass) var sizeClass
    @State var animationDelay = 0.5
    
    var body: some View {
        ZStack {
            VStack {
                HStack (alignment: .center){
                    DepartmentSelectorView(viewModel: viewModel, fireSelected: $viewModel.showFires, showComments: $viewModel.showMostRecentComments)
                }
                .padding(.horizontal)
                
                if (viewModel.showMostRecentComments) {
                    RecentCommentsView(viewModel: viewModel)
                        .transition(.move(edge: .trailing).combined(with: .scale))
                    
                } else if (viewModel.showFires) {
                    if (viewModel.fires.count == 0 && !viewModel.isRefreshing) {
                        VStack {
                            
                            Spacer()
                            
                            Text("No Matches Found")
                                .font(.system(size: 25))
                            
                            Text("Adjust your filter settings")
                                .font(.system(size: 15))
                            
                            Image(systemName: "flame")
                                .foregroundColor(.red)
                                .font(.system(size: 40))
                                .padding()
                            
                            Spacer()
                        }
                        .onTapGesture {
                            viewModel.refreshFires()
                        }
                        
                    } else {
                        NavigationView {
                            List(viewModel.fires, id: \.self) { fire in
                                
                                ActivityRowView(activity: fire, viewModel: viewModel)
                                    .opacity(viewModel.fires.count > 0 ? 1 : 0)
                                    .animation(Animation.easeOut(duration: 0.6).delay(animationDelay), value: viewModel.fires.count > 0)
                                
                                if (fire == viewModel.fires.last) {
                                    if (viewModel.isLoading) {
                                        ProgressView()
                                            .frame(idealWidth: .infinity, maxWidth: .infinity, alignment: .center)
                                            .listRowSeparator(.hidden)
                                    } else {
                                        HStack (alignment: .center){
                                            Text("Get More")
                                                .bold()
                                                .italic()
                                                .foregroundColor(.blue)
                                                .frame(idealWidth: .infinity, maxWidth: .infinity, alignment: .center)
                                        }
                                        .onTapGesture {
                                            withAnimation {
                                                viewModel.getMoreFires()
                                            }
                                        }
                                    }
                                }
                                
                            }
                        }
                        .refreshable {
                            viewModel.refreshFires()
                        }
                        .transition(.move(edge: .trailing).combined(with: .scale))
                        
                        .padding(.top, -10)
                    }
                
                } else  { // Show normal activity view
                    // If count = 0, likely filtered and no applicable results
                    if (viewModel.activities.count == 0 && !viewModel.isRefreshing) {
                        VStack {
                            
                            Spacer()
                            
                            Text("No Matches Found")
                                .font(.system(size: 25))
                            
                            Text("Adjust your filter settings")
                                .font(.system(size: 15))
                            
                            HStack {
                                Spacer()
                                
                                Image(systemName: "light.beacon.min")
                                    .foregroundColor(.blue)
                                    .font(.system(size: 40))
                                    .padding(.vertical)
                                
                                Image(systemName: "light.beacon.min")
                                    .foregroundColor(.red)
                                    .font(.system(size: 40))
                                    .padding(.vertical)


                                
                                Spacer()
                            }
                                                      
                            Spacer()
                        }
                        .onTapGesture {
                            viewModel.refreshActivities()
                        }
                        // Results
                    } else {
                        NavigationView {
                            
                            List(viewModel.activities, id: \.self) { activity in
                                
                                ActivityRowView(activity: activity, viewModel: viewModel)
                                    .opacity(viewModel.activities.count > 0 ? 1 : 0)
                                    .animation(Animation.easeOut(duration: 0.6).delay(animationDelay), value: viewModel.activities.count > 0)
                                
                                if (activity == viewModel.activities.last) {
                                    if (viewModel.isLoading) {
                                        ProgressView()
                                            .frame(idealWidth: .infinity, maxWidth: .infinity, alignment: .center)
                                            .listRowSeparator(.hidden)
                                    } else {
                                        HStack (alignment: .center){
                                            Text("Get More")
                                                .bold()
                                                .italic()
                                                .foregroundColor(.blue)
                                                .frame(idealWidth: .infinity, maxWidth: .infinity, alignment: .center)
                                        }
                                        .onTapGesture {
                                            withAnimation {
                                                viewModel.getMoreActivities()
                                            }
                                        }
                                    }
                                }
                            }
                            .refreshable {
                                viewModel.refreshActivities()
                            }
                        }
                        .transition(.move(edge: .leading).combined(with: .scale))
                        .padding(.top, -10)
                    }
                }
//                SwiftUIBannerAd(adPosition: .bottom, adUnitId: Constants.appID)
//                    .ignoresSafeArea()
//                    .frame(maxHeight: 40)
            }
            .onAppear(perform: {
                withAnimation {
                    UITableView.appearance().contentInset.top = -35
                }
            })
            
            // Refresh Reminder Capsule
            if showingRefreshReminder && !viewModel.showBookmarks {
                RefreshReminderView(viewModel: viewModel, showingRefreshReminder: $showingRefreshReminder)
            }
        }
        .onChange(of: scenePhase) { newPhase in
            switch newPhase {
                
            case .background:
                showRefreshReminderOnActive = true
                viewModel.getBookmarks()
            case .active:
                if showRefreshReminderOnActive {
                    withAnimation(.spring()) {showingRefreshReminder = true}
                }
                viewModel.getBookmarks()
            case .inactive:
                print("G - App Inactive ¯\\_(ツ)_/¯")
            @unknown default:
                print("G - App Inactive ¯\\_(ツ)_/¯")
            }
        }
    }
}

struct ListView_Previews: PreviewProvider {
    static var previews: some View {
        ListView(viewModel: MainViewModel())
            .environmentObject(AppDelegate())
    }
}
