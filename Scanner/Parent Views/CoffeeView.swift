//
//  SettingsView.swift
//  Scanner
//
//  Created by Kyle Kincer on 1/19/22.
//

import SwiftUI

struct CoffeeView: View {
    @Binding var showCoffee: Bool
    
    var body: some View {
        VStack {
            Capsule()
                .fill(Color.secondary)
                .frame(width: 30, height: 3)
                .padding(10)
            
            Spacer()
            
            Text("Buy Us A Coffee")
                .fontWeight(.black)
                .italic()
                .font(.largeTitle)
                .shadow(radius: 2)
                .foregroundColor(Color("ModeOpposite"))
                .padding(.bottom)
            
            ZStack {
                Image(systemName: "cup.and.saucer.fill")
                    .font(.system(size: 100))
                    .foregroundColor(.brown)
                
                Image(systemName: "water.waves")
                    .font(.system(size: 100))
                    .scaleEffect(x: 0.4, y: 0.6)
                    .foregroundColor(.red)
                    .rotationEffect(Angle(degrees: 90))
                    .offset(y: -50)
                    .shadow(radius: 2)
            }
            
            Text("Scanner remains free to use, but if you'd like to buy us a coffee, use the button below. We appreciate your support!")
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
                .fixedSize(horizontal: false, vertical: true)
            
            ZStack {
                Capsule()
                    .fill(.brown)
                    .frame(width: 150, height: 50)
                    .padding(10)
                
                Link("Click Here", destination: URL(string: "https://www.buymeacoffee.com/kylekincer")!)
                    .foregroundColor(.white)
                
            }
            
            Spacer()
        }
    }
}

struct CoffeeView_Previews: PreviewProvider {
    static var previews: some View {
        CoffeeView(showCoffee: .constant(true))
    }
}
