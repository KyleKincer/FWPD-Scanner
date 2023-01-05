//
//  ProfilePhoto.swift
//  Scanner
//
//  Created by Kyle Kincer on 12/23/22.
//

import SwiftUI

struct ProfilePhoto: View {
    let url: URL?
    let size: CGFloat
    
    var body: some View {
        VStack {
            if let url = url {
                ZStack {
                    Circle()
                        .foregroundColor(Color("ModeOpposite"))
                        .frame(width: size, height: size)
                    
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .frame(width: size - 3, height: size - 3)
                            .clipShape(Circle())
                    } placeholder: {
                        Image(systemName: "person.crop.circle")
                            .foregroundColor(.orange)
                            .font(.system(size: 80))
                    }
                }
                
            } else {
                Image(systemName: "person.crop.circle")
                    .foregroundColor(.orange)
                    .font(.system(size: 80))
            }
        }
    }
}

struct ProfilePhoto_Previews: PreviewProvider {
    static var previews: some View {
        ProfilePhoto(url: nil, size: CGFloat(5.0))
    }
}
