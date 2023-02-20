//
//  RecentCommentsView.swift
//  Scanner
//
//  Created by Kyle Kincer on 12/11/22.
//

import SwiftUI

struct RecentCommentsView: View {
    @ObservedObject var viewModel: MainViewModel
    
    var body: some View {
        ZStack {
            if (viewModel.recentlyCommentedActivities.count == 0) {
                VStack {
                    
                    Spacer()
                    
                    Text("No recently commented activities")
                        .font(.system(size: 25))
                        .padding()
                        .multilineTextAlignment(.center)
                    
                    ZStack {
                        Image(systemName: "clock")
                            .foregroundColor(.orange)
                            .font(.system(size: 40))
                            .padding()
                    }
                    
                    Spacer()
                }
                .onTapGesture {
                    if (viewModel.showFires) {
                        viewModel.refreshFires()
                    } else {
                        viewModel.refreshActivities()
                    }
                }
            } else {
                NavigationView {
                    Section {
                        List(viewModel.recentlyCommentedActivities, id: \.self) { activity in
                            ActivityRowView(activity: activity, viewModel: viewModel)
                        }
                    }
                    .navigationBarTitleDisplayMode(.inline)
                }
                .refreshable {
                    viewModel.getRecentlyCommentedActivities(getFires: viewModel.showFires)
                }
            }
        }
    }
}

struct RecentCommentsView_Previews: PreviewProvider {
    static var previews: some View {
        RecentCommentsView(viewModel: MainViewModel())
    }
}
