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
            if (appDelegate.openedFromNotification) {
                ZStack {
                    NotificationView(viewModel: viewModel, activity: $appDelegate.notificationActivity)
                        .padding(.top, 25)
                    
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
                        .padding(.horizontal)
                        
                        Spacer()
                    }
                }
                
            } else {
                switch sizeClass {
                case .compact:
                    ZStack {
                        if (showMap) {
                            MapView(chosenActivity: $chosenActivity, activities: (viewModel.showBookmarks ? $viewModel.bookmarks : $viewModel.activities), viewModel: viewModel)
                                .edgesIgnoringSafeArea(.all)
                                .transition(.opacity)
                        }
                        
                        if (!showMap) {
                            VStack {
                                if #available(iOS 16.0, *) {
                                    NavigationStack {
                                        ListView(viewModel: viewModel)
                                    }
                                    
                                } else {
                                    ListView(viewModel: viewModel)
                                }
                            }
                            .onAppear {
                                chosenActivity = nil
                            }
                            .transition(.opacity)
                        }
                    }
                default:
                    VStack {
                        if (showMap) {
                            MapView(chosenActivity: $chosenActivity, activities: viewModel.showBookmarks ? $viewModel.bookmarks : $viewModel.activities, viewModel: viewModel)
                                .edgesIgnoringSafeArea(.all)
                                .transition(.opacity)
                            
                        } else {
                            if #available(iOS 16.0, *) {
                                NavigationSplitView {
                                    ListView(viewModel: viewModel)
                                }
                            detail: {
                                VStack {
                                    Text("Select an event to view details")
                                        .italic()
                                        .bold()
                                        .padding()
                                    
                                    Image(systemName: "mail.stack")
                                        .font(.system(size: 50))
                                                                        
                                }
                            }
                                
                            .navigationSplitViewStyle(.balanced)
                            .navigationBarTitleDisplayMode(.inline)
                            .onAppear {
                                chosenActivity = nil
                            }
                            } else {
                                VStack {
                                    
                                    HStack {
                                        
                                        Text((viewModel.useDate || viewModel.useNature || viewModel.useLocation) ? "Police Filtered" : (viewModel.showMostRecentComments ? "Comments" : "Police"))
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
                                    
                                    Spacer()
                                    
                                    if (viewModel.showMostRecentComments) {
                                        RecentCommentsView(viewModel: viewModel)
                                    } else {
                                        ListView(viewModel: viewModel)
                                    }
                                }
                                .transition(.opacity)
                            }
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
            .environmentObject(AppDelegate())
    }
}
