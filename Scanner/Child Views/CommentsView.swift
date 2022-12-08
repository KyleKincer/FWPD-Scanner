//
//  CommentsView.swift
//  Scanner
//
//  Created by Kyle Kincer on 12/3/22.
//

import SwiftUI
import FirebaseFirestore
import FirebaseCore
import FirebaseAuth

struct CommentsView: View {
    @ObservedObject var viewModel: MainViewModel
    @StateObject var commentModel = CommentsViewModel()
    @Binding var activity: Scanner.Activity
    @State var comment: String = ""
    @State var showLoginSheet = false
    @State var showSubmit = false
    @FocusState var commentIsFocused: Bool
    @State var authHandle : AuthStateDidChangeListenerHandle?
    
    var body: some View {
        VStack (alignment: .leading) {
            HStack {
                
                Text("Comments")
                    .bold()
                
                if viewModel.loggedIn {
                    Spacer()
                    
                    Text(viewModel.username)
                        .foregroundColor(.gray)
                } else {
                    Spacer()
                    
                    Button {
                        showLoginSheet = true
                    } label: {
                        ZStack {
                            Capsule()
                                .frame(width: 100, height: 35)
                                .foregroundColor(.red)
                            HStack {
                                Image(systemName: "person.fill.questionmark")
                                    .foregroundColor(.white)
                                Text("Login")
                                    .foregroundColor(.white)
                                    .fontWeight(.bold)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal)
            
            HStack {
                TextField("Type comment here...", text: $comment)
                    .keyboardType(.default)
                    .focused($commentIsFocused)
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
                
                if (showSubmit && viewModel.loggedIn) {
                    Button() {
                        playHaptic()
                        commentModel.submitComment(activityId: activity.id, comment: comment, userId: viewModel.userId, userName: viewModel.username)
                        activity.commentCount!+=1
                        commentIsFocused = false
                        comment = ""
                    } label: {
                        ZStack{
                            RoundedRectangle(cornerRadius: 15)
                            Text("Submit").fontWeight(.semibold)
                                .tint(.white)
                        }.frame(width: 100, height: 35)
                    }.disabled(comment.isEmpty)
                }
            }
            .onAppear(perform: {
                commentModel.startListening(activityId: activity.id)
                
                authHandle = Auth.auth().addStateDidChangeListener { auth, user in
                    
                }
                
            })
            .onDisappear(perform: {
                commentModel.stopListening()
                
                Auth.auth().removeStateDidChangeListener(authHandle!)
                
            })
            
            VStack (alignment: .leading) {
                ForEach(commentModel.comments.sorted(by: { $0.timestamp.seconds < $1.timestamp.seconds })) { comment in
                    CommentView(comment: comment)
                }
            }
            .padding(.horizontal)
            .onChange(of: commentModel.comments, perform: { _ in
                commentModel.comments = commentModel.comments
            })
            .sheet(isPresented: $showLoginSheet, content: {
                LoginView(viewModel: viewModel)
            })
        }
    }
}

struct CommentView: View {
    let comment: Comment
    var body: some View {
        HStack {
            Image(systemName: "person.circle")
                .foregroundColor(.gray)
            VStack(alignment: .leading) {
                HStack {
                    Text(comment.userName)
                        .font(.headline)
                        .foregroundColor(.gray)
                    Spacer()
                    Text(comment.timestamp.firebaseTimestamp.dateValue().formatted())
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                Text(comment.text)
            }
        }
        .padding(.vertical, 4)
    }
}



struct CommentsView_Previews: PreviewProvider {
    static var previews: some View {
        CommentsView(viewModel: MainViewModel(), activity: .constant(Scanner.Activity(id: "1116", timestamp: "06/07/1998 - 01:01:01", nature: "Wild Kyle Appears", address: "5522 Old Dover Blvd", location: "Canterbury Green", controlNumber: "10AD43", longitude: -85.10719687273503, latitude: 41.13135945131842, commentCount: 3)))
    }
}
