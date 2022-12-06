//
//  CommentsView.swift
//  Scanner
//
//  Created by Kyle Kincer on 12/3/22.
//

import SwiftUI
import FirebaseFirestore

struct CommentsView: View {
    @State var viewModel: MainViewModel
    @StateObject var commentModel = CommentsViewModel()
    @Binding var activity: Scanner.Activity
    @State var comment: String = ""
    @State var showUserNameSheet = false
    @State var showSubmit = false
    
    var body: some View {
        VStack (alignment: .leading) {
            HStack {
                
                Text("Comments")
                    .bold()
                
                if viewModel.commentUser != "" {
                    Spacer()
                    
                    Text(viewModel.commentUser)
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal)
            
            HStack {
                TextField("Type comment here...", text: $comment)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.trailing)
                    .onChange(of: comment.count) { newValue in
                        if (newValue > 0) {
                            withAnimation {
                                showSubmit = true
                            }
                        } else {
                            withAnimation {
                                showSubmit = false
                            }
                        }
                    }
                    .keyboardType(.emailAddress)
                
                if (showSubmit && viewModel.commentUser != "") {
                    Button() {
                        playHaptic()
                        commentModel.submitComment(activityId: activity.id, comment: comment, userName: viewModel.commentUser)
                        comment = ""
                    } label: {
                        ZStack{
                            RoundedRectangle(cornerRadius: 15)
                            Text("Submit").fontWeight(.semibold)
                                .tint(.white)
                        }.frame(width: 100, height: 35)
                    }.disabled(comment.isEmpty)
                }
                
                if (viewModel.commentUser == "") {
                    Button() {
                        playHaptic()
                        showUserNameSheet = true
                    } label: {
                        ZStack{
                            RoundedRectangle(cornerRadius: 15)
                            Text("Set Name").fontWeight(.semibold)
                                .tint(.white)
                        }.frame(width: 150, height: 35)
                    }
                }
            }
            .onAppear(perform: { commentModel.startListening(activityId: activity.id) })
            .onDisappear(perform: { commentModel.stopListening() })
            
            VStack (alignment: .leading) {
                ForEach(commentModel.comments.sorted(by: { $0.timestamp.seconds < $1.timestamp.seconds })) { comment in
                    HStack {
                        Text(comment.user + ": ")
                            .foregroundColor(.gray)
                        
                        Text(comment.text)
                            .foregroundColor(.white)
                    }
                    .padding(.vertical, 4)
                    
                }
            }
            .padding(.horizontal)
            .fullScreenCover(isPresented: $showUserNameSheet, content: {
                LoginView(viewModel: viewModel)
            })
        }
    }
}
                         
    
struct CommentsView_Previews: PreviewProvider {
    static var previews: some View {
        CommentsView(viewModel: MainViewModel(), activity: .constant(Scanner.Activity(id: "1116", timestamp: "06/07/1998 - 01:01:01", nature: "Wild Kyle Appears", address: "5522 Old Dover Blvd", location: "Canterbury Green", controlNumber: "10AD43", longitude: -85.10719687273503, latitude: 41.13135945131842)))
    }
}
