//
//  ScanModeComingView.swift
//  Scanner
//
//  Created by Nick Molargik on 10/11/22.
//

import SwiftUI

import SwiftUI

struct ScanModeComingView: View {
    var body: some View {
        
        VStack {
            Capsule()
                    .fill(Color.secondary)
                    .frame(width: 30, height: 3)
                    .padding(10)
            
            Text("Scanning Mode")
                .fontWeight(.black)
                .italic()
                .font(.largeTitle)
                .shadow(radius: 2)
                .foregroundColor(Color("ModeOpposite"))
            
            Spacer()
            
            ZStack {
                
                Image(systemName: "camera.metering.center.weighted")
                    .foregroundColor(.red)
                    .font(.system(size: 110))
                
                Image(systemName: "exclamationmark.triangle")
                    .foregroundColor(.white)
                    .font(.system(size: 20))
            }
            
            Spacer()
            
            Text("Scanning Mode provides the most recent information in the form of a Live Activity widget on the Lock Screen and, where available, the Dynamic Island.")
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
            

            Text("Coming... eventually 🫠")
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Spacer()
        }
    }
}

struct ScanModeComingView_Previews: PreviewProvider {
    static var previews: some View {
        ScanModeComingView()
    }
}
