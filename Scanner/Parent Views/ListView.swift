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
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    
                    Text((viewModel.useDate || viewModel.useNature || viewModel.useLocation) ? "Filtered Activity" : (viewModel.showMostRecentComments ? "Recent Comments" : "Recent Activity"))
                        .font(.title)
                    
                    Spacer()
                    
                    if (!viewModel.useDate && !viewModel.useNature && !viewModel.useLocation) {
                        
                        Button(action: {
                            withAnimation {
                                viewModel.showMostRecentComments.toggle()
                            }
                        }, label: {
                            Image(systemName: viewModel.showMostRecentComments ? "bubble.right" : "clock")
                                .font(.system(size: 25))
                        })
                    }
                }
                .padding(.horizontal)
                
                if (viewModel.showMostRecentComments) {
                    RecentCommentsView(viewModel: viewModel)
                } else  { // Show normal activity view
                    // If count = 0, likely filtered and no applicable results
                    if (viewModel.activities.count == 0 && !viewModel.isRefreshing) {
                        VStack {
                            
                            Spacer()
                            
                            Text("No Matches Found")
                                .font(.system(size: 25))
                            
                            Text("Adjust your filter settings")
                                .font(.system(size: 15))
                            
                            Image(systemName: "doc.text.magnifyingglass")
                                .foregroundColor(.blue)
                                .font(.system(size: 40))
                                .padding()
                            
                            Spacer()
                        }
                        // Results
                    } else {
                        NavigationView {
                            
                            List(viewModel.activities, id: \.self) { activity in
                                ActivityRowView(activity: activity, viewModel: viewModel)
                                
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
                                            viewModel.getMoreActivities()
                                        }
                                    }
                                }
                            }
                            .refreshable {
                                viewModel.refresh()
                            }
                        }
                    }
                }
                SwiftUIBannerAd(adPosition: .bottom, adUnitId: Constants.appID)
                    .ignoresSafeArea()
                    .frame(maxHeight: 40)
            }
            
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
    }
}
