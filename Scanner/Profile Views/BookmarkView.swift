//
//  BookmarkView.swift
//  Scanner
//
//  Created by Nick Molargik on 11/20/22.
//

import SwiftUI

struct BookmarkView: View {
    @ObservedObject var viewModel: MainViewModel

    var body: some View {
        ZStack {
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
                }
            }
        }
        .onAppear {
            if (viewModel.bookmarkCount != viewModel.bookmarks.count) {
                viewModel.getBookmarks()
            }
        }
    }
}

struct BookmarkView_Previews: PreviewProvider {
    static var previews: some View {
        BookmarkView(viewModel: MainViewModel())
    }
}
