//
//  UniversalBackButton.swift
//  Scanner
//
//  Created by Nick Molargik on 12/13/22.
//

import SwiftUI

struct BackButtonView: View {
    @State var text : String
    @State var color : Color
    
    var body: some View {
        HStack {
            Image(systemName: "arrow.left")
                .foregroundColor(color)
                .font(.system(size: 30))
            
            Text(text)
                .foregroundColor(color)
            
            Spacer()
        }.padding([.leading, .top])
    }
}

struct BackButtonView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            BackButtonView(text: "Back", color: Color.blue)
            BackButtonView(text: "Filters", color: Color.green)
            BackButtonView(text: "Log In", color: Color.orange)
            BackButtonView(text: "Save", color: Color.red)
        }
    }
}
