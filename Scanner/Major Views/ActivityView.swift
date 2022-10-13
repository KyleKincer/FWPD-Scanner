//
//  ActivityView.swift
//  Scanner
//
//  Created by Nick Molargik on 9/29/22.
//

import SwiftUI

struct ActivityView: View {
    @Environment(\.horizontalSizeClass) var sizeClass
    @Binding var showMap : Bool
    @State private var showFilter = false
    @ObservedObject var viewModel : ScannerActivityListViewModel
    
    var body: some View {
        switch sizeClass {
            case .compact:
            ZStack {
                VStack {
                    if (showMap) {
                        MapView(viewModel: viewModel)
                            .edgesIgnoringSafeArea(.all)
                    } else {
                        if #available(iOS 16.0, *) {
                            NavigationStack {
                                List(viewModel.activities) {
                                    if viewModel.isLoading {
                                        if $0 == viewModel.activities.first {
                                            HStack {
                                                Spacer()
                                                ProgressView()
                                                    .progressViewStyle(CircularProgressViewStyle())
                                                Spacer()
                                            }
                                        }
                                    } else {
                                        ActivityRowView(activity: $0)
                                    }
                                    
                                }.refreshable {
                                    viewModel.refresh()
                                }
                            }
                        } else {
                            ScannerActivityListView(viewModel: viewModel)
                                .animation(.linear, value: showMap)
                        }
                    }
                }
            }
        default:
            VStack {
                if (showMap) {
                    MapView(viewModel: viewModel)
                        .edgesIgnoringSafeArea(.all)
                    
                } else {
                    if #available(iOS 16.0, *) {
                        NavigationSplitView {
                            VStack {
                                if (showFilter) {
                                    ExpandedFilterSettings(viewModel: viewModel)
                        
                                } else {
                                    List(viewModel.activities) {
                                        if viewModel.isLoading {
                                            if $0 == viewModel.activities.first {
                                                HStack {
                                                    Spacer()
                                                    ProgressView()
                                                        .progressViewStyle(CircularProgressViewStyle())
                                                    Spacer()
                                                }
                                            }
                                        } else {
                                            ActivityRowView(activity: $0)
                                                
                                        }
                                    }
                                    .refreshable {
                                        viewModel.refresh()
                                    }
                                }
                            }
                            .navigationTitle(showFilter ? "Filters" : "Recent Events")
                            .navigationBarBackButtonHidden()
                            .toolbar {
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
                    detail: {
                        Text("Select an event to view details")
                    }
                        
                    .navigationSplitViewStyle(.balanced)
                    .navigationBarTitleDisplayMode(.inline)
                    
                        
                    } else {
                        ScannerActivityListView(viewModel: viewModel)
                    }
                }
            }
        }
    }
}

struct ActivityView_Previews: PreviewProvider {
    static var previews: some View {
        ActivityView(showMap: .constant(false), viewModel: ScannerActivityListViewModel())
    }
}
