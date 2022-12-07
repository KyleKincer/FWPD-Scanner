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
    @State var viewModel: MainViewModel
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
                
                if viewModel.username != "" {
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
                    .keyboardType(.emailAddress)
                
                if (showSubmit && viewModel.username != "") {
                    Button() {
                        playHaptic()
                        activity.commentCount = commentModel.submitComment(activityId: activity.id, comment: comment, userId: viewModel.userId, userName: viewModel.username)
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
                    HStack {
                        Text(comment.userName + ": ")
                            .foregroundColor(.gray)
                        
                        Text(comment.text)
                            .foregroundColor(.white)
                    }
                    .padding(.vertical, 4)
                    
                }
            }
            .padding(.horizontal)
            .sheet(isPresented: $showLoginSheet, content: {
                LoginView(viewModel: viewModel)
            })
        }
    }
}


struct CommentsView_Previews: PreviewProvider {
    static var previews: some View {
        CommentsView(viewModel: MainViewModel(), activity: .constant(Scanner.Activity(id: "1116", timestamp: "06/07/1998 - 01:01:01", nature: "Wild Kyle Appears", address: "5522 Old Dover Blvd", location: "Canterbury Green", controlNumber: "10AD43", longitude: -85.10719687273503, latitude: 41.13135945131842, commentCount: 3)))
    }
}
