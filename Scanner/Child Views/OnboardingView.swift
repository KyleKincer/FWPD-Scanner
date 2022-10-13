//
//  OnboardingView.swift
//  Scanner
//
//  Created by Nick Molargik on 10/11/22.
//

import SwiftUI

struct OnboardingView: View {
    
    @Environment(\.colorScheme) var colorScheme
    @AppStorage("onboarding") var onboarding = true
    @State var isAnimating = false
    
    var body: some View {
        VStack {
            Text("Welcome to")
                .italic()
            Text("Scanner")
                .fontWeight(.black)
                .font(.largeTitle)
                .italic()
                .shadow(radius: 2)
                .foregroundColor(Color("ModeOpposite"))
                .scaleEffect(2)
            
            if (colorScheme == .light) {
                Image("launchicon")
                    .colorInvert()
                    .scaleEffect(self.isAnimating ? 0.3 : 0.5)
                    .onAppear {
                        withAnimation (.linear(duration: 1).repeatForever()) {
                            self.isAnimating = true
                        }
                    }
                    .frame(width: 200, height: 200)
            } else {
                Image("launchicon")
                    .scaleEffect(self.isAnimating ? 0.3 : 0.5)
                    .onAppear {
                        withAnimation (.linear(duration: 1).repeatForever()){
                            self.isAnimating = true
                        }
                    }
                    .frame(width: 200, height: 200)
            }
            
            Spacer()
            
            Text("One-Time Disclaimer")
                .fontWeight(.bold)
            
            Text("Activities listed in scanner are posted by the Fort Wayne Police Department. All information provided is sourced directly from FWPD. Activites are not posted as they happen, but rather as soon as FWPD posts them.")
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            
            Text("If you are experiencing an emergency, dial 911.")
                .fontWeight(.bold)
                .padding()
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                
            
            Spacer()
            
            Button(action: {
                onboarding = false
            }, label: {
                ZStack {
                    Capsule()
                        .frame(width: 150, height: 75)
                    
                    Text("Let's Go")
                        .foregroundColor(.white)
                        .fontWeight(.bold)
                }
            })
        }
        .padding()
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}
