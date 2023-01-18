//
//  DepartmentSelector.swift
//  Scanner
//
//  Created by Nick Molargik on 1/16/23.
//

import SwiftUI

struct DepartmentSelectorView: View {
    @ObservedObject var viewModel: MainViewModel
    @Binding var fireSelected : Bool
    @Binding var showComments : Bool
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    withAnimation (.linear){
                        fireSelected = false
                        playHaptic()
                        viewModel.getRecentlyCommentedActivities(getFires: fireSelected)
                    }
                }, label: {
                    Text("👮‍♂️   Police")
                        .fontWeight(.bold)
                        .font(!fireSelected ? .title : .subheadline)
                        .foregroundColor(!fireSelected ? .blue : .gray)
                })
                
                Spacer()
                
                Button(action: {
                    withAnimation (.linear){
                        fireSelected = true
                        playHaptic()
                        viewModel.getRecentlyCommentedActivities(getFires: fireSelected)
                    }
                }, label: {
                    Text("Fire   👨‍🚒")
                        .fontWeight(.bold)
                        .font(fireSelected ? .title : .subheadline)
                        .foregroundColor(fireSelected ? .red : .gray)
                })
            }
            .padding(.horizontal)

            if (!(viewModel.useDate || viewModel.useNature || viewModel.useLocation)) {
                
                Divider()
                    .padding(.horizontal)
                
                HStack {
                    Button(action: {
                        withAnimation (.interactiveSpring()) {
                            showComments = false
                            playHaptic()
                        }
                    }, label: {
                        Text("Activity")
                            .fontWeight(.semibold)
                            .font(!showComments ? .title2 : .subheadline)
                            .foregroundColor(!showComments ? (fireSelected ? .red : .blue) : .gray)
                    })
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation (.interactiveSpring()) {
                            showComments = true
                            playHaptic()
                        }
                    }, label: {
                        Text("Comments")
                            .fontWeight(.semibold)
                            .font(showComments ? .title2 : .subheadline)
                            .foregroundColor(showComments ? (fireSelected ? .red : .blue) : .gray)
                    })
                }
                .padding(.horizontal)
                .padding(.top, 2)
            } else {
                Text("Filtered")
                    .fontWeight(.semibold)
                    .font(.title2)
                    .foregroundColor(.green)
                    .padding(.horizontal)
                    .padding(.top, 2)
            }
        }
    }
}

struct DepartmentSelectorView_Previews: PreviewProvider {
    static var previews: some View {
        DepartmentSelectorView(viewModel: MainViewModel(), fireSelected: .constant(false), showComments: .constant(false))
    }
}
