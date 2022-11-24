//
//  OnboardingView.swift
//  Scanner
//
//  Created by Nick Molargik on 10/11/22.
//

import SwiftUI

struct OnboardingView: View {
    
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var viewModel : MainViewModel
    @AppStorage("onboarding") var onboarding = true
    @State var isAnimating = true
    
    var body: some View {
        ZStack {
            if (colorScheme == .light) {
                Color.white.edgesIgnoringSafeArea(.all)
            } else {
                Color.black.edgesIgnoringSafeArea(.all)
            }
            
            VStack {
                Group {
                    Spacer()
                    
                    Text("Welcome to")
                        .italic()
                    Text("Scanner")
                        .fontWeight(.black)
                        .font(.largeTitle)
                        .italic()
                        .shadow(radius: 2)
                        .foregroundColor(Color("ModeOpposite"))
                        .scaleEffect(2)
                    
                    StatusView(viewModel: viewModel)
                        .scaleEffect(0.5)
                        .frame(width: 400, height: 100)
                        .padding()
                    
                    Spacer()
                    
                    Text("One-Time Disclaimer:")
                        .fontWeight(.bold)
                    
                    Text("Activities listed in scanner are posted by the Fort Wayne Police Department. All information provided is sourced directly from FWPD. Activites are not posted as they happen, but rather as soon as FWPD posts them.")
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: false)
                        .padding(.horizontal, 50)
                    
                    Text("If you are experiencing an emergency, dial 911.")
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: false)
                        .padding(.horizontal, 30)
                        .padding(.top)
                                    
                    Spacer()
                }
                
                Button(action: {
                    playHaptic()
                    withAnimation {
                        onboarding = false
                    }
                }, label: {
                    ZStack {
                        Capsule()
                            .frame(width: 250, height: 75)
                            .foregroundColor(.blue)
                        
                        Text("Let's Get Scanning!")
                            .foregroundColor(.white)
                            .fontWeight(.bold)
                    }
                }).padding(.bottom, 50)
                    .onAppear {
                        onboarding = true
                        viewModel.locationManager.requestAlwaysAuthorization()
                    }
                    .onDisappear {
                        viewModel.selectedNaturesUD.removeAll()
                        viewModel.refresh()
                    }
                
                Spacer()
            }
        }.padding()
            .transition(.opacity)
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(viewModel: MainViewModel())
    }
}
