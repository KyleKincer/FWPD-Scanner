//
//  ActivityView.swift
//  Scanner
//
//  Created by Nick Molargik on 9/29/22.
//

import SwiftUI

struct ActivityView: View {
    @Environment(\.horizontalSizeClass) var sizeClass
    @Environment(\.colorScheme) var colorScheme
    @Binding var showMap : Bool
    @State private var showFilter = false
    @State var status = 0
    @State var chosenActivity : Scanner.Activity?
    @ObservedObject var viewModel : ScannerActivityListViewModel
    
    var body: some View {
        switch sizeClass {
            case .compact:
            ZStack {
                MapView(chosenActivity: $chosenActivity, viewModel: viewModel)
                    .edgesIgnoringSafeArea(.all)
                
                
                if (showMap==false) {
                    if (colorScheme == .light) {
                        Color.white
                            .edgesIgnoringSafeArea(.all)
                    } else {
                        Color.black
                            .edgesIgnoringSafeArea(.all)
                    }
                    VStack {
                        if (viewModel.isLoading) {
                            
                            Spacer()
                            
                            StatusView(viewModel: viewModel)
                                .onTapGesture {
                                    if (!viewModel.serverResponsive) {
                                        withAnimation (.linear(duration: 0.5)) {
                                            viewModel.serverResponsive = true
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                                withAnimation {
                                                    viewModel.serverResponsive = false
                                                    viewModel.refresh()
                                                }
                                            }
                                        }
                                    }
                                }
                            
                            Spacer()
                            
                        } else {
                            if #available(iOS 16.0, *) {
                                NavigationStack {
                                    ScannerActivityListView(viewModel: viewModel)
                                }
                                
                            } else {
                                ScannerActivityListView(viewModel: viewModel)
                                    .animation(.linear, value: showMap)
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
                    MapView(chosenActivity: $chosenActivity, viewModel: viewModel)
                        .edgesIgnoringSafeArea(.all)
                    
                } else {
                    if #available(iOS 16.0, *) {
                        NavigationSplitView {
                            VStack {
                                if (viewModel.isLoading) {
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
                                } else {
                                    if (showFilter) {
                                        ExpandedFilterSettings(viewModel: viewModel)
                                        
                                    } else {
                                        List(viewModel.activities) { activity in
                                            ActivityRowView(activity: activity)
                                        }
                                        .refreshable {
                                            viewModel.refresh()
                                        }
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
                    .onAppear {
                        chosenActivity = nil
                    }
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
