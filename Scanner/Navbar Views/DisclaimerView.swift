//
//  LocationDisclaimerView.swift
//  Scanner
//
//  Created by Nick Molargik on 10/11/22.
//

import SwiftUI

struct DisclaimerView: View {
    let version = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
    let build = Bundle.main.infoDictionary!["CFBundleVersion"] as! String
    
    var body: some View {
        VStack {
            
            Spacer()
            
            Text("Location Disclaimer")
                .font(.title2)
                .italic()
                .bold()
                .shadow(radius: 2)
            
            Image(systemName: "location.magnifyingglass")
                .foregroundColor(.blue)
                .font(.system(size: 60))
                .padding(2)
            
            Text("Fort Wayne Scanner collects your precise location to provide information on the closest FWPD and FWFD activities when certain filters are applied. All other times, location is used to display the distance between you and the location of reported activites.\nYour location is never shared to third-party vendors.")
                .multilineTextAlignment(.center)
                .padding()
                .font(.footnote)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
            
            Text("v\(version) - \(build)")
                .foregroundColor(.gray)
                .font(.footnote)
                .padding()
        }
    }
}

struct DisclaimerView_Previews: PreviewProvider {
    static var previews: some View {
        DisclaimerView()
    }
}
