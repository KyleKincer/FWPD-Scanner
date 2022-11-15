//
//  ScanModeComingView.swift
//  Scanner
//
//  Created by Nick Molargik on 10/11/22.
//

import SwiftUI

import SwiftUI

struct NotificationsComingView: View {
    var body: some View {
        
        VStack {
            Capsule()
                    .fill(Color.secondary)
                    .frame(width: 30, height: 3)
                    .padding(10)
            
            Text("Notifications")
                .fontWeight(.black)
                .italic()
                .font(.largeTitle)
                .shadow(radius: 2)
                .foregroundColor(Color("ModeOpposite"))
            
            Text("Coming Soon")
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
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
            
            Text("Notifications will provide the most recent information in the form of push notification, a Live Activity widget on the Lock Screen and, where available, the Dynamic Island.")
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
        }
    }
}

struct NotificationsComingView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationsComingView()
    }
}
