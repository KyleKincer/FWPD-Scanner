//
//  ActivityCell.swift
//  Scanner
//
//  Created by Kyle Kincer on 1/17/22.
//

import SwiftUI
import CoreData

struct ActivityRowView: View {
    @State var activity: Scanner.Activity
    @AppStorage("showDistance") var showDistance = true
    @ObservedObject var viewModel : MainViewModel
    
    var body: some View {
        NavigationLink(destination: {DetailView(viewModel: viewModel, activity: $activity)}) {
            VStack(spacing: 5) {
                if (showDistance && activity.distance ?? 0 > 0.0 && !viewModel.showBookmarks) {
                    HStack {
                        Text(activity.nature == "" ? "Unknown" : activity.nature.capitalized)
                            .font(.body)
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.leading)
                            .lineLimit(1)
                            .minimumScaleFactor(0.75)
                        
                        Spacer()
                        
                        Text("\(activity.date ?? Date(), style: .relative)")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.trailing)
                            .lineLimit(1)
                    }
                    
                    HStack {
                        Image(systemName: activity.bookmarked ? "bookmark.fill" : "mappin.and.ellipse")
                            .foregroundColor(activity.bookmarked ? .orange : .primary)
                        
                        Text("\(String(format: "%g", round(10 * (activity.distance ?? 0)) / 10)) miles away")
                        
                        Spacer()
                        
                        Text(activity.location.capitalized)
                        
                    }
                    .font(.footnote)
                    
                    HStack {
                        Text(activity.address.capitalized)
                            .font(.footnote)
                        Spacer()
                    }
                    .font(.footnote)
                } else {
                    
                    HStack {
                        Text(activity.nature == "" ? "Unknown" : activity.nature.capitalized)
                            .font(.body)
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.leading)
                            .lineLimit(1)
                            .minimumScaleFactor(0.75)
                            .foregroundColor(activity.bookmarked ? .orange : .primary)
                        
                        Spacer()
                    }
                    
                    if (!viewModel.showBookmarks) {
                        HStack {
                            Text("\(activity.date ?? Date(), style: .relative) ago")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.trailing)
                                .lineLimit(1)
                            
                            Spacer()
                            
                        }
                    }
                    
                    HStack {
                        Text(activity.address.capitalized)
                            .font(.footnote)
                        Spacer()
                    }
                    
                    HStack {
                        Text(activity.location)
                            .font(.footnote)
                        
                        Spacer()
                    }
                }
            }
        }
        .contextMenu {
            Button {
                if activity.bookmarked {
                    activity.bookmarked = false
                    viewModel.removeBookmark(bookmark: activity)
                    if (viewModel.showBookmarks) {
                        withAnimation {
                            viewModel.activities.removeAll { $0.controlNumber == activity.controlNumber }
                        }
                    }
                } else {
                    activity.bookmarked = true
                    viewModel.addBookmark(bookmark: activity)
                }
            } label: {
                Text("Toggle Bookmark")
            }
        }
        .swipeActions {
            Button(activity.bookmarked ? "Unmark" : "Bookmark") {
                if activity.bookmarked {
                    activity.bookmarked = false
                    viewModel.removeBookmark(bookmark: activity)
                    if (viewModel.showBookmarks) {
                        withAnimation {
                            viewModel.activities.removeAll { $0.controlNumber == activity.controlNumber }
                        }
                    }
                } else {
                    activity.bookmarked = true
                    viewModel.addBookmark(bookmark: activity)
                }
            }.tint(activity.bookmarked ? .red : .orange)
        }
    
        .onAppear {
            let bookmarkState = viewModel.checkBookmark(bookmark: activity)
            activity.bookmarked = bookmarkState
        }
    }
}

struct ActivityRowView_Previews: PreviewProvider {
    static var previews: some View {
        ActivityRowView(activity: Scanner.Activity(id: 1116, timestamp: "06/07/1998 - 01:01:01", nature: "Wild Kyle Appears", address: "5522 Old Dover Blvd", location: "Canterbury Green", controlNumber: "10AD43", longitude: -85.10719687273503, latitude: 41.13135945131842), viewModel: MainViewModel())
            .frame(width: 200, height: 100)
    }
}
