//
//  ScannerActivityListView.swift
//  Scanner
//
//  Created by Kyle Kincer on 1/11/22.
//

import SwiftUI

struct ScannerActivityListView: View {
    @ObservedObject var viewModel: ScannerActivityListViewModel
    @Environment(\.scenePhase) var scenePhase
    @State var showingRefreshReminder = false
    @State var showRefreshReminderOnActive = false
    @State var showingFilterPopover = false
    @State var radius = 1.0
    @State var isEditing = false
    @State var startingOffsetY: CGFloat = 100.0
    @State var currentDragOffsetY: CGFloat = 0
    
    var body: some View {
        ZStack {  
            VStack {
                NavigationView {
                    List(viewModel.activities) { activity in
                        if viewModel.isLoading {
                            if activity == viewModel.activities.first {
                                HStack {
                                    Spacer()
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle())
                                    Spacer()
                                }
                            }
                        } else {
                            ActivityRowView(activity: activity)
                                .onAppear {
                                    viewModel.getMoreActivitiesIfNeeded(currentActivity: activity)
                                }
                                
                        }
                    }.refreshable {
                        withAnimation {
                            viewModel.refresh()
                            showingRefreshReminder = false
                        }
                    }
                    .navigationTitle("Recent Events")
                    .navigationBarTitleDisplayMode(.automatic)
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
                }
            }.transition(.move(edge: .bottom))
            
            if showingRefreshReminder {
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
                }.transition(.move(edge: .top))
            }
        }
    }
}

struct ScannerActivityListView_Previews: PreviewProvider {
    static var previews: some View {
        ScannerActivityListView(viewModel: ScannerActivityListViewModel())
    }
}
