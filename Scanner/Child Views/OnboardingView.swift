//
//  OnboardingView.swift
//  Scanner
//
//  Created by Nick Molargik on 10/11/22.
//

import SwiftUI

struct OnboardingView: View {
    
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var viewModel : ScannerActivityListViewModel
    @AppStorage("onboarding") var onboarding = true
    @State var isAnimating = false
    
    var body: some View {
        ZStack {
            if (colorScheme == .light) {
                Color.white.edgesIgnoringSafeArea(.all)
            } else {
                Color.black.edgesIgnoringSafeArea(.all)
            }
            
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
                    .padding(.bottom, 60)
                
                StatusView(viewModel: viewModel)
                
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
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(viewModel: ScannerActivityListViewModel())
    }
}
