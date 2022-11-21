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
        ZStack {
            colorScheme == .light ? Color.white : Color.black // Background
            
            // StatusView if necessary
            if (viewModel.isRefreshing || (!viewModel.showBookmarks && !viewModel.serverResponsive)) {
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
             
            // MapView if necessary
            } else if (showMap) {
                MapView(chosenActivity: $chosenActivity, activities: (viewModel.showBookmarks ? $viewModel.bookmarks : $viewModel.activities), viewModel: viewModel)
                    .edgesIgnoringSafeArea(.all)
                
            // Show ListView
            } else {
                if (sizeClass == .compact) {
                    if #available(iOS 16.0, *) {
                        NavigationStack {
                            ListView(viewModel: viewModel)
                        }
                        
                    } else {
                        ListView(viewModel: viewModel)
                    }
                } else {
                    if #available(iOS 16.0, *) {
                        NavigationSplitView {
                            ListView(viewModel: viewModel)
                        }
                        detail: {
                            VStack {
                                Text("Select an event to view details")
                                    .padding(20)
                                    .fontWeight(.semibold)
                                    
                                Image(systemName: "square.stack.3d.down.forward.fill")
                                    .scaleEffect(3)
                                    .padding(20)
                                
                            }.font(.system(size: 30))
                        }
                        .navigationSplitViewStyle(.balanced)
                        .navigationBarTitleDisplayMode(.inline)
                    } else {
                        ListView(viewModel: viewModel)
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
