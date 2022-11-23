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
                // Show BookmarkView
                if (viewModel.showBookmarks) {
                    BookmarkView(viewModel: viewModel)
                    
                // Show activities
                } else {
                    // If count = 0, likely filtered and no applicable results
                    if (viewModel.activities.count == 0) {
                        VStack {
                            Text("No Matches Found")
                                .font(.system(size: 25))
                            
                            Text("Adjust your filter settings")
                                .font(.system(size: 15))
                            
                            Image(systemName: "doc.text.magnifyingglass")
                                .foregroundColor(.blue)
                                .font(.system(size: 40))
                                .padding()
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
                            .listStyle(.sidebar)
                            .id(UUID())
                            .navigationBarTitleDisplayMode(.automatic)
                            .navigationTitle((viewModel.useDate || viewModel.useNature || viewModel.useLocation) ? "Filtered Activity" : "Recent Activity")
                            .refreshable {
                                viewModel.refresh()

                            }
                        }
                    }
                }
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
                print("G - App Inactive (shrug)")
            @unknown default:
                print("G - App Inactive (shrug)")
            }
        }
    }
}

struct ListView_Previews: PreviewProvider {
    static var previews: some View {
        ListView(viewModel: MainViewModel())
    }
}
