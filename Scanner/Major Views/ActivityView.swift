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
                                        Text(viewModel.bookmarkCount == 0 ? "No Bookmarks Saved" : "Gathering Bookmarks")
                                            .foregroundColor(.primary)
                                            .font(.system(size: 25))
                                            .padding()
                                        Image(systemName: "bookmark")
                                            .foregroundColor(.orange)
                                            .font(.system(size: 20))
                                    }
                                    
                                } else {
                                    if (showFilter) {
                                        ExpandedFilterSettings(viewModel: viewModel)
                                        
                                    } else {
                                        List(viewModel.bookmarks) { activity in
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
                            }
                            .navigationTitle(showFilter ? "Filters" : (viewModel.showBookmarks ? "Bookmarks" : "Recent Activity"))
                            .navigationBarBackButtonHidden()
                            .toolbar {
                                if (viewModel.serverResponsive) {
                                    ToolbarItem(placement: .navigationBarTrailing) {
                                        Button(action: {
                                            withAnimation {
                                                showFilter.toggle()
                                            }
                                        }, label: {
                                            Image(systemName: "camera.filters")
                                                .font(.system(size: 18))
                                                .foregroundColor(.green)
                                                .shadow(radius: 2)
                                        })
                                    }
                                }
                            }
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
