//
//  WatchOnboardingView.swift
//  WatchScanner
//
//  Created by Nick Molargik on 11/16/22.
//

import SwiftUI

struct WatchOnboardingView: View {
    
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var viewModel : WatchViewModel
    @State var isAnimating = true
    
    var body: some View {
        ScrollView {
            VStack {
                Text("Welcome to")
                    .italic()
                Text("Scanner")
                    .fontWeight(.black)
                    .font(.callout)
                    .italic()
                    .shadow(radius: 2)
                    .scaleEffect(1.5)
                    .padding(.bottom)
                
                Text("One-Time Disclaimer")
                    .fontWeight(.bold)
                
                Text("Activities listed in scanner are posted by the Fort Wayne Police Department. All information provided is sourced directly from FWPD and FWFD. Activites are not posted as they happen, but rather as soon as the respective department posts them.")
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding()
                
                Text("If you are experiencing an emergency, dial 911.")
                    .fontWeight(.bold)
                    .padding()
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundColor(.blue)
                        .frame(width: 80, height: 40)
                    
                    Text("Let's Go")
                        .foregroundColor(.white)
                        .onTapGesture {
                            withAnimation {
                                viewModel.playHaptic()
                                viewModel.onboarding = false
                                viewModel.onboardingUD = false
                            }
                        }
                }
            }
            .transition(.opacity)
            .onAppear {
                viewModel.onboarding = true
            }
        }.transition(.slide)
    }
}

struct WatchOnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        WatchOnboardingView(viewModel: WatchViewModel())
    }
}
