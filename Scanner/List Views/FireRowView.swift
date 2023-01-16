//
//  FireRowView.swift
//  Scanner
//
//  Created by Nick Molargik on 1/16/23.
//

import SwiftUI

struct FireRowView: View {
    @State var fire: Scanner.Fire
    @ObservedObject var viewModel : MainViewModel
    
    var body: some View {
        VStack(alignment: .center ,spacing: 5) {
            HStack {
                Text(fire.nature == "" ? "Unknown" : fire.nature.capitalized)
                    .font(.body)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.leading)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                    .foregroundColor(fire.bookmarked ? .orange : .primary)
            }
            
            HStack {
                Text("\(fire.date ?? Date(), style: .relative) ago")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.trailing)
                    .lineLimit(1)
            }
            
            HStack {
                Text(fire.address.capitalized)
                    .font(.footnote)
            }
        }
        .contextMenu {
            Button {
                if fire.bookmarked {
                    withAnimation {
                        fire.bookmarked = false
                        //viewModel.removeBookmark(bookmark: activity)
                        if (viewModel.showBookmarks) {
                            viewModel.fires.removeAll { $0.controlNumber == fire.controlNumber }
                        }
                    }
                } else {
                    withAnimation {
                        fire.bookmarked = true
                        //viewModel.addBookmark(bookmark: activity)
                    }
                }
            } label: {
                Text("Toggle Bookmark")
                
            }
        }
        .swipeActions {
            if (viewModel.loggedIn) {
                Button(fire.bookmarked ? "Unmark" : "Bookmark") {
                    if fire.bookmarked {
                        withAnimation {
                            fire.bookmarked = false
                            //viewModel.removeBookmark(bookmark: activity)
                        }
                        if (viewModel.showBookmarks) {
                            withAnimation {
                                viewModel.bookmarks.removeAll { $0.controlNumber == fire.controlNumber }
                            }
                        }
                    } else {
                        withAnimation {
                            fire.bookmarked = true
                            //viewModel.addBookmark(bookmark: activity)
                        }
                    }
                }.tint(fire.bookmarked ? .red : .orange)
            }
        }
        
        .onAppear {
            //let bookmarkState = viewModel.checkBookmark(bookmark: activity)
            //activity.bookmarked = bookmarkState
        }
    }
}

struct FireRowView_Previews: PreviewProvider {
    static var previews: some View {
        FireRowView(fire: Scanner.Fire(id: "123456", timestamp: "right meow", nature: "Big Ole Fire", address: "Yer mom's house", controlNumber: "1A2B3C", commentCount: 2), viewModel: MainViewModel())
    }
}
