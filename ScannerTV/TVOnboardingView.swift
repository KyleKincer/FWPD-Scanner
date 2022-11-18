//
//  TVOnboardingView.swift
//  ScannerTV
//
//  Created by Nick Molargik on 10/12/22.
//

import SwiftUI

struct TVOnboardingView: View {
    
    @Environment(\.colorScheme) var colorScheme
    @AppStorage("onboarding") var onboarding = true
    @State var isAnimating = false
    
    var body: some View {
        ZStack {
            if (colorScheme == .light) {
                Color.white
                    .edgesIgnoringSafeArea(.all)
            } else {
                Color.black
                    .edgesIgnoringSafeArea(.all)
            }
            
            VStack {
                
                Spacer()
                
                HStack {
                    Spacer()
                    
                    VStack {
                        Text("Welcome to")
                            .italic()
                        
                        Text("Scanner")
                            .italic()
                            .bold()
                            .font(.system(size: 100))
                            .font(.largeTitle)
                            .shadow(radius: 2)
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                    }
                    
                    Spacer()
                    
                    VStack {
                        if (colorScheme == .light) {
                            Image("launchicon")
                                .scaleEffect(self.isAnimating ? 1 : 3)
                                .frame(width: 100, height: 100)
                                .colorInvert()
                            
                        } else {
                            Image("launchicon")
                                .scaleEffect(self.isAnimating ? 1 : 3)
                                .frame(width: 100, height: 100)
                        }
                    }.onAppear {
                        withAnimation (.linear(duration: 1).repeatForever()) {
                            self.isAnimating = true
                        }
                    }
                    
                    Spacer()
                    
                }.padding()

                Spacer()
                
                Text("One-Time Disclaimer")
                    .fontWeight(.bold)
                    .padding(.bottom, 0)
                
                Text("Activities listed in scanner are posted by the Fort Wayne Police Department. All information provided is sourced directly from FWPD. Activites are not posted as they happen, but rather as soon as FWPD posts them.")
                    .padding(.horizontal)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                
                Text("If you are experiencing an emergency, dial 911.")
                    .fontWeight(.bold)
                    .padding()
                    .multilineTextAlignment(.center)
                    
                
                Spacer()
                
                Button(action: {
                    onboarding = false
                }, label: {
                    Text("Let's Go")
                        .foregroundColor(.blue)
                        .fontWeight(.bold)
                })
                .padding()
                .foregroundColor(colorScheme == .dark ? .white : .black)
            }
        }
    }
}

struct TVOnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        TVOnboardingView()
    }
}
