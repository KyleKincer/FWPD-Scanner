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
    @State var showSubmit = false
    @FocusState var commentIsFocused: Bool
    @State var authHandle : AuthStateDidChangeListenerHandle?
    @State var signingUp : Bool = false
    
    var body: some View {
        VStack (alignment: .leading) {
            HStack {
                
                Text("Comments")
                    .bold()
                    .font(.system(size: 20))
                
                if viewModel.loggedIn {
                    Spacer()
                    
                    Text(viewModel.username)
                        .foregroundColor(.gray)
                } else {
                    Spacer()
                    
                    Button {
                        viewModel.showAuth = true
                    } label: {
                        ZStack {
                            Capsule()
                                .frame(width: 100, height: 35)
                                .foregroundColor(.orange)
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
                            withAnimation(.easeInOut) {
                                showSubmit = true
                            }
                        } else {
                            withAnimation(.easeInOut) {
                                showSubmit = false
                            }
                        }
                    }
                
                if (showSubmit && viewModel.loggedIn) {
                    Button() {
                        playHaptic()
                        commentModel.submitComment(activityId: activity.id, comment: comment, userId: viewModel.userId, userName: viewModel.username)
                        activity.commentCount! = activity.commentCount! + 1
                        
                        if let index = viewModel.activities.firstIndex(where: {$0.controlNumber == activity.controlNumber}) {
                            viewModel.activities[index].commentCount!+=1
                        }
                        
                        commentIsFocused = false
                        comment = ""
                    } label: {
                        ZStack{
                            RoundedRectangle(cornerRadius: 15)
                            Text("Submit").fontWeight(.semibold)
                                .tint(.white)
                        }.frame(width: 100, height: 35)
                    }
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
                ForEach(commentModel.comments.sorted(by: { $0.timestamp.seconds > $1.timestamp.seconds })) { comment in
                    CommentView(comment: comment, admin: viewModel.admin)
                        .contextMenu {
                            if viewModel.admin {
                                Button {
                                    commentModel.deleteComment(comment: comment, activityId: activity.id)
                                    activity.commentCount!-=1
                                } label: {
                                    Text("Delete")
                                }
                                
                                Button {
                                    withAnimation {
                                        commentModel.hideComment(comment: comment, activityId: activity.id)
                                    }
                                } label: {
                                    Text(comment.hidden ? "Unhide" : "Hide")
                                }
                                
                            }
                        }
                }
            }
            .padding(.horizontal)
            .onChange(of: commentModel.comments, perform: { _ in
                commentModel.comments = commentModel.comments
            })
            .fullScreenCover(isPresented: $viewModel.showAuth, content: {
                if (signingUp) {
                    RegisterView(viewModel: viewModel, signingUp: $signingUp, showPage: $viewModel.showAuth)
                } else {
                    LoginView(viewModel: viewModel, signingUp: $signingUp, showPage: $viewModel.showAuth)
                }
            })
        }
    }
}



struct CommentsView_Previews: PreviewProvider {
    static var previews: some View {
        CommentsView(viewModel: MainViewModel(), activity: .constant(Scanner.Activity(id: "1116", timestamp: "06/07/1998 - 01:01:01", nature: "Wild Kyle Appears", address: "5522 Old Dover Blvd", location: "Canterbury Green", controlNumber: "10AD43", longitude: -85.10719687273503, latitude: 41.13135945131842, commentCount: 3)))
    }
}
