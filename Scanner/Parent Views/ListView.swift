//
//  ListView.swift
//  Scanner
//
//  Created by Kyle Kincer on 1/11/22.
//

import SwiftUI

struct ListView: View {
    @ObservedObject var viewModel: MainViewModel
    @Environment(\.scenePhase) var scenePhase
    @State var showingRefreshReminder = false
    @State var showRefreshReminderOnActive = false
    @State var showingFilterPopover = false
    @State var radius = 1.0
    @State var isEditing = false
    @State var startingOffsetY: CGFloat = 100.0
    @State var currentDragOffsetY: CGFloat = 0
    @State var showMap : Bool
    
    var body: some View {
        ZStack {
            VStack {
                // Recent Activity
                if (!viewModel.showBookmarks) {
                    NavigationView {
                        Section {
                            if (viewModel.activities.count == 0 && !viewModel.isLoading && !viewModel.isRefreshing) {
                                VStack {
                                    Text("No Matches Found")
                                        .font(.system(size: 25))
                                    
                                    Text("Adjust your filter settings")
                                        .font(.system(size: 15))
                                    
                                    ZStack {
                                        Image(systemName: "doc.text.magnifyingglass")
                                            .foregroundColor(.blue)
                                            .font(.system(size: 40))
                                            .padding()
                                    }
                                }
                            } else {
                                List(viewModel.activities, id: \.self) { activity in
                                    ActivityRowView(activity: activity, viewModel: viewModel)
                                    
                                    if (activity == viewModel.activities.last && !viewModel.useLocation) {
                                        Section {
                                            if (viewModel.isLoading) {
                                                ProgressView()
                                                    .frame(idealWidth: .infinity, maxWidth: .infinity, alignment: .center)
                                                    .listRowSeparator(.hidden)
                                            } else {
                                                HStack {
                                                    Spacer()
                                                    
                                                    Text("Tap for More")
                                                        .bold()
                                                        .italic()
                                                        .foregroundColor(.blue)
                                                        .frame(idealWidth: .infinity, maxWidth: .infinity, alignment: .center)
                                                    
                                                    Spacer()
                                                }
                                                .onTapGesture {
                                                    viewModel.getMoreActivities()
                                                }
                                                
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .navigationTitle((viewModel.useDate || viewModel.useNature || viewModel.useLocation) ? "Filtered Activity" : "Recent Activity")
                        .navigationBarTitleDisplayMode(.automatic)
                        .refreshable {
                            withAnimation {
                                viewModel.refresh()
                                showingRefreshReminder = false
                            }
                        }
                    }
                } else {
                    
                    //Bookmarks
                    if (viewModel.bookmarks.count == 0) {
                        VStack {
                            Text("No Bookmarks Saved")
                                .font(.system(size: 25))
                            
                            ZStack {
                                Image(systemName: "bookmark")
                                    .foregroundColor(.orange)
                                    .font(.system(size: 40))
                                    .padding()
                            }
                        }
                    } else {
                        NavigationView {
                            Section {
                                List(viewModel.bookmarks, id: \.self) { activity in
                                    ActivityRowView(activity: activity, viewModel: viewModel)
                                }
                            }
                            .navigationTitle("Bookmarks")
                            .navigationBarTitleDisplayMode(.automatic)
                        }
                    }
                }
            }
            .onChange(of: scenePhase) { newPhase in
                switch newPhase {
                    
                case .background:
                    showRefreshReminderOnActive = true
                case .active:
                    if showRefreshReminderOnActive {
                        withAnimation(.spring()) {showingRefreshReminder = true}
                    }
                case .inactive:
                    print("G - App Inactive (shrug)")
                @unknown default:
                    print("G - App Inactive (shrug)")
                }
            }
            if showingRefreshReminder && !viewModel.showBookmarks {
                VStack {
                    Button() {
                        withAnimation {
                            playHaptic()
                            viewModel.refresh()
                        }
                        withAnimation(.spring()) {showingRefreshReminder.toggle()}
                    } label: {
                        ZStack{
                            RoundedRectangle(cornerRadius: 15)
                            HStack {
                                Text("Refresh").fontWeight(.semibold)
                                Image(systemName: "arrow.clockwise")
                            }
                            .tint(.white)
                        }.frame(width: 120, height: 33)
                            .padding(.bottom)
                    }
                    .offset(y: startingOffsetY)
                    .offset(y: currentDragOffsetY)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                currentDragOffsetY = value.translation.height
                            }
                            .onEnded{ value in
                                if value.translation.height < 0 {
                                    withAnimation(.spring()) {showingRefreshReminder = false}
                                }
                            }
                    )
                    
                    Spacer()
                    
                }
                .transition(.move(edge: .top))
            }
        }
    }
}

struct ListView_Previews: PreviewProvider {
    static var previews: some View {
        ListView(viewModel: MainViewModel(), showMap: false)
    }
}
