//
//  ScanModeSettingsView.swift
//  Scanner
//
//  Created by Nick Molargik on 10/11/22.
//

import SwiftUI

@available(iOS 16.1, *)
struct ScanModeSettingsView: View {
    @AppStorage("enableLiveActivities") var live = true
    @AppStorage("scanOn") var scanning = false
    @State var helper = LiveActivityHelper()
    
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
            }.onTapGesture {
                if (scanning) {
                    helper.update(activity: Scanner.Activity(id: 1116, timestamp: "06/07/1998 - 01:01:01", nature: "Wild Kyle Appears", address: "5522 Old Dover Blvd", location: "Canterbury Green", controlNumber: "10AD43", longitude: -85.10719687273503, latitude: 41.13135945131842, distance: 10))
                }
            }
            
            Spacer()
            
            Text("Scanning Mode provides the most recent information in the form of a Live Activity widget on the Lock Screen and, where available, the Dynamic Island. These events are still only available once posted by FWPD; typically an hour after the event occurs.")
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
            
            ZStack {
                Capsule()
                    .fill(live ? (scanning ? .red : .blue) : .orange)
                        .frame(width: 200, height: 50)
                        .padding(10)
                
                    if (live) {
                        Button (action: {
                            if (scanning) {
                                scanning = false
                                helper.end()
                            } else {
                                // Start the live activity
                                helper.start()
                                scanning = true
                            }
                        }, label: {
                            if (scanning) {
                                Text("Disable Scanning Mode")
                                    .foregroundColor(.white)
                                    .fontWeight(.semibold)
                            } else {
                                Text("Enable Scanning Mode")
                                    .foregroundColor(.white)
                                    .fontWeight(.semibold)
                            }
                        })
                    } else {
                        Button (action: {
                            live = true
                        }, label: {
                            Text("Enable Live Activities")
                        })
                    }
            }
            
            Spacer()
        }
    }
}

@available(iOS 16.1, *)
struct ScanModeSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        ScanModeSettingsView()
    }
}
