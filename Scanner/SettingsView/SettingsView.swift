//
//  SettingsView.swift
//  Scanner
//
//  Created by Kyle Kincer on 1/19/22.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("useLocation") var useLocation = false
    @AppStorage("radius") var radius = 10.0
    
    var body: some View {
        List {
            Section("Location settings") {
                Toggle(isOn: $useLocation) {
                    Text("Filter based on current location: ")
                        .font(.body)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                }
                VStack {
                    HStack {
                        Text("Radius: \(String(format: "%g", (round(radius * 10)) / 10)) mi")
                        Spacer()
                    }
                    Slider(value: $radius, in: 0.1...20)
                }
            }
            Section("Notification settings") {
                Text("Coming soon!")
            }
            Section("Donate") {
                Link("Click here to donate ☕️", destination: URL(string: "https://www.buymeacoffee.com/kylekincer")!)
            }
            
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
