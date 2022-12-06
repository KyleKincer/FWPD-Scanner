//
//  CommentsView.swift
//  Scanner
//
//  Created by Kyle Kincer on 12/3/22.
//

import SwiftUI
import FirebaseFirestore

struct CommentsView: View {
    @ObservedObject var viewModel: CommentsViewModel
    var activity: Scanner.Activity
    @State var comment: String = ""
    
    init(activity: Scanner.Activity) {
        self.viewModel = CommentsViewModel()
        self.activity = activity
    }
    
    var body: some View {
        Text("Comments")
        HStack {
            TextField("Type comment here...", text: $comment)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.trailing)
            
            Button() {
                playHaptic()
                viewModel.submitComment(activityId: activity.id, comment: comment)
                comment = ""
            } label: {
                ZStack{
                    RoundedRectangle(cornerRadius: 15)
                    Text("Submit").fontWeight(.semibold)
                        .tint(.white)
                }.frame(width: 100, height: 35)
            }.disabled(comment.isEmpty)
        }
        .onAppear(perform: { viewModel.startListening(activityId: activity.id) })
        .onDisappear(perform: { viewModel.stopListening() })
        
        VStack {
            ForEach(viewModel.comments) { comment in
                Text(comment.user)
                Text(comment.text)
            }
        }
    }
    
    //    struct CommentsView_Previews: PreviewProvider {
    //        static var previews: some View {
    //            CommentsView(viewModel: CommentsViewModel(), activity: (Scanner.Activity(id: "1116", timestamp: "06/07/1998 - 01:01:01", nature: "Wild Kyle Appears", address: "5522 Old Dover Blvd", location: "Canterbury Green", controlNumber: "10AD43", longitude: -85.10719687273503, latitude: 41.13135945131842)))
    //        }
    //    }
}
