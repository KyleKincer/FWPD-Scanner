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
                            List(viewModel.activities) { activity in
                                ActivityRowView(activity: activity, viewModel: viewModel)
                                
                                if (activity == viewModel.activities.last) {
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
                                                if (activity == viewModel.activities.last && !viewModel.isLoading) {
                                                    viewModel.getMoreActivities()
                                                }
                                            }
                                            
                                        }
                                    }
                                }
                            }
                        }
                        .navigationTitle("Recent Activity")
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
                    if (viewModel.activities == []) {
                        VStack {
                            Text("Gathering bookmarks...")
                                .font(.system(size: 25))
                                .padding(.bottom)
                            
                            ZStack {
                                ProgressView()
                                    .scaleEffect(3)
                                Image(systemName: "bookmark")
                                    .foregroundColor(.yellow)
                            }
                        }
                    } else {
                        NavigationView {
                            Section {
                                List(viewModel.activities) { activity in
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
                    print("shrug")
                @unknown default:
                    print("shrug")
                }
            }
            if showingRefreshReminder && !viewModel.showBookmarks {
                VStack {
                    Button() {
                        viewModel.refresh()
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
