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
                        showComments = false
                    }
                }, label: {
                    Text("Fire   👨‍🚒")
                        .fontWeight(.bold)
                        .font(fireSelected ? .title : .subheadline)
                        .foregroundColor(fireSelected ? .red : .gray)
                })
            }
            .padding(.horizontal)

            if (!fireSelected && !(viewModel.useDate || viewModel.useNature || viewModel.useLocation)) {
                
                Divider()
                    .padding(.horizontal)
                
                HStack {
                    Button(action: {
                        withAnimation (.interactiveSpring()) {
                            showComments = false
                        }
                    }, label: {
                        Text("Recent Activity")
                            .fontWeight(.semibold)
                            .font(!showComments ? .title2 : .subheadline)
                            .foregroundColor(!showComments ? .blue : .gray)
                    })
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation (.interactiveSpring()) {
                            showComments = true
                        }
                    }, label: {
                        Text("Recent Comments")
                            .fontWeight(.semibold)
                            .font(showComments ? .title2 : .subheadline)
                            .foregroundColor(showComments ? .blue : .gray)
                    })
                }
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
