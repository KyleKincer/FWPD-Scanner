//
//  LoginView.swift
//  Scanner
//
//  Created by Kyle Kincer on 12/6/22.
//

import SwiftUI

struct LoginView: View {
    @State var viewModel: MainViewModel
    @Environment(\.presentationMode) var presentationMode
    @State var userNameInput = ""
    @State var rulesMet = false
    @State var alert = ""
    
    var body: some View {
        VStack {
            Text("User Name")
                .fontWeight(.black)
                .italic()
                .font(.largeTitle)
                .shadow(radius: 2)
                .padding(.vertical)
                .foregroundColor(Color("ModeOpposite"))
            
            Image(systemName: "person.circle")
                .foregroundColor(.blue)
                .padding()
                .font(.system(size: 60))
            
            Text("This user name can only be set one time and will be shown on all of your community activity comments. Please use good judgement in selecting a username.")
                .multilineTextAlignment(.center)
            
            Spacer()
            
            if (alert != "") {
                Text(alert)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            
            TextField("User Name", text: $userNameInput)
                .padding()
                .border(.white)
                .onChange(of: userNameInput) { newValue in
                    // UserName Rules
                    rulesMet = true
                    alert = ""
                    
                    if (userNameInput == "") {
                        rulesMet = false
                        alert.append("Username cannot be blank!\n")
                    }
                    
                    if (userNameInput.contains(" ")) {
                        rulesMet = false
                        alert.append("Username cannot contain spaces!\n")
                    }
                    
                    if (userNameInput.count < 3) {
                        rulesMet = false
                        alert.append("Username must be 3 characters or more!\n")
                    }
                    
                    if (userNameInput.count > 30) {
                        rulesMet = false
                        alert.append("Username must be 30 characters or fewer!\n")
                    }
                }
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }, label: {
                    ZStack {
                        Capsule()
                            .frame(width: 100, height: 50)
                            .foregroundColor(.red)
                        
                        Text("Cancel")
                            .foregroundColor(.white)
                            .fontWeight(.bold)
                    }
                })
                .padding()
                
                Spacer()
                
                Button(action: {
                    viewModel.commentUser = userNameInput
                    presentationMode.wrappedValue.dismiss()
                }, label: {
                    ZStack {
                        Capsule()
                            .frame(width: 100, height: 50)
                            .foregroundColor(rulesMet ? .blue : .gray)
                        
                        Text("Save")
                            .foregroundColor(.white)
                            .fontWeight(.bold)
                    }
                })
                .disabled(!rulesMet)
                .padding()
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(viewModel: MainViewModel())
    }
}
