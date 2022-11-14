//
//  ActivityView.swift
//  Scanner
//
//  Created by Nick Molargik on 9/29/22
//

import SwiftUI

struct ActivityView: View {
    @Environment(\.horizontalSizeClass) var sizeClass
    @Environment(\.colorScheme) var colorScheme
    @Binding var showMap : Bool
    @State private var showFilter = false
    @State var status = 0
    @State var chosenActivity : Scanner.Activity?
    @ObservedObject var viewModel : MainViewModel
    
    var body: some View {
        switch sizeClass {
            case .compact:
            ZStack {
                if (showMap) {
                    MapView(chosenActivity: $chosenActivity, activities: (viewModel.showBookmarks ? $viewModel.bookmarks : $viewModel.activities), viewModel: viewModel)
                        .edgesIgnoringSafeArea(.all)
                }
                
                if (showMap==false) {
                    if (colorScheme == .light) {
                        Color.white
                            .edgesIgnoringSafeArea(.all)
                    } else {
                        Color.black
                            .edgesIgnoringSafeArea(.all)
                    }
                    VStack {
                        if (viewModel.isRefreshing) {
                            
                            Spacer()
                            
                            StatusView(viewModel: viewModel)
                                .onTapGesture {
                                    if (!viewModel.serverResponsive) {
                                        withAnimation {
                                            viewModel.serverResponsive = true
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                                viewModel.serverResponsive = false
                                                viewModel.refresh()
                                            }
                                        }
                                    }
                                }
                            
                            Spacer()
                            
                        } else {
                            if #available(iOS 16.0, *) {
                                NavigationStack {
                                    ListView(viewModel: viewModel, showMap: showMap)
                                }
                                
                            } else {
                                ListView(viewModel: viewModel, showMap: showMap)
                            }
                        }
                    }
                    .onAppear {
                        chosenActivity = nil
                    }
                }
            }
        default:
            VStack {
                if (showMap) {
                    MapView(chosenActivity: $chosenActivity, activities: viewModel.showBookmarks ? $viewModel.bookmarks : $viewModel.activities, viewModel: viewModel)
                        .edgesIgnoringSafeArea(.all)
                    
                } else {
                    if #available(iOS 16.0, *) {
                        NavigationSplitView {
                            VStack {
                                if (viewModel.isRefreshing) {
                                    Spacer()
                                    
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
                                    
                                    Spacer()
                                } else if (viewModel.showBookmarks) {
                                    VStack {
                                        if (viewModel.bookmarkCount == 0) {
                                            Text("No Bookmarks Saved")
                                                .foregroundColor(.primary)
                                                .font(.system(size: 25))
                                                .padding()
                                            Image(systemName: "bookmark")
                                                .foregroundColor(.orange)
                                                .font(.system(size: 20))
                                        } else if (viewModel.bookmarks.count != viewModel.bookmarkCount) {
                                            Text("Gathering Bookmarks")
                                                .foregroundColor(.primary)
                                                .font(.system(size: 25))
                                                .padding()
                                            Image(systemName: "bookmark")
                                                .foregroundColor(.orange)
                                                .font(.system(size: 20))
                                        }
                                        
                                        
                                        else {
                                            List(viewModel.bookmarks) { activity in
                                                ActivityRowView(activity: activity, viewModel: viewModel)
                                            }
                                            
                                        }
                                    }
                                    .onAppear {
                                        if (viewModel.bookmarkCount != viewModel.bookmarks.count) {
                                            viewModel.getBookmarks()
                                        }
                                    }
                                    
                                    
                                } else if (viewModel.activities.count == 0 && !viewModel.isLoading && !viewModel.isRefreshing) {
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
                                    List(viewModel.activities) { activity in
                                        ActivityRowView(activity: activity, viewModel: viewModel)
                                    }
                                    
                                    if (!viewModel.showBookmarks) {
                                        Section {
                                            if (viewModel.isLoading) {
                                                ProgressView()
                                                    .frame(idealWidth: .infinity, maxWidth: .infinity, alignment: .center)
                                                    .listRowSeparator(.hidden)
                                            } else {
                                                Text("Tap for More")
                                                    .bold()
                                                    .italic()
                                                    .foregroundColor(.blue)
                                                    .frame(idealWidth: .infinity, maxWidth: .infinity, alignment: .center)
                                                    .onTapGesture {
                                                        viewModel.getMoreActivities()
                                                    }
                                                    .padding(.trailing, -2)
                                            }
                                        }
                                    }
                                }
                            }
                            .navigationTitle(showFilter ? "Filters" : (viewModel.showBookmarks ? "Bookmarks" : "Recent Activity"))
                            .navigationBarBackButtonHidden()
                        }
                    detail: {
                        Text("Select an event to view details")
                    }
                        
                    .navigationSplitViewStyle(.balanced)
                    .navigationBarTitleDisplayMode(.inline)
                    .onAppear {
                        chosenActivity = nil
                    }
                    } else {
                        ListView(viewModel: viewModel, showMap: showMap)
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
