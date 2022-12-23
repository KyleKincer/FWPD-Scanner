//
//  ProfileEditView.swift
//  Scanner
//
//  Created by Kyle Kincer on 12/23/22.
//

import SwiftUI

struct ProfileEditView: View {
    @ObservedObject var viewModel : MainViewModel
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct ProfileEditView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileEditView(viewModel: MainViewModel())
    }
}
