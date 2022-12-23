//
//  ProfilePhoto.swift
//  Scanner
//
//  Created by Kyle Kincer on 12/23/22.
//

import SwiftUI
import Drops

struct ProfilePhoto: View {
    let url: URL?
    
    var body: some View {
        if let url = url {
            ZStack {
                Circle()
                    .foregroundColor(.white)
                    .frame(width: 100, height: 100)
                
                AsyncImage(url: url) { image in
                    image
                        .clipShape(Circle())
                } placeholder: {
                    Image(systemName: "person.crop.circle")
                        .foregroundColor(.gray)
                        .font(.system(size: 80))
                }
            }
            
        } else {
            Image(systemName: "person.crop.circle")
                .foregroundColor(.gray)
                .font(.system(size: 80))
        }
    }
}

//struct ProfilePhoto_Previews: PreviewProvider {
//    static var previews: some View {
//        ProfilePhoto()
//    }
//}
