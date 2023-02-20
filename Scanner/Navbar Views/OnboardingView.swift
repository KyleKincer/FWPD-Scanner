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
    @State var isAnimating = false
    @State private var showInfo = false
    @State var signingUp = false
    
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
                    
                    Text("Fort Wayne")
                        .italic()
                        .fontWeight(.bold)
                        .font(.title)
                        .padding(.top)
                    
                    Text("Scanner")
                        .fontWeight(.black)
                        .font(.system(size: 70))
                        .italic()
                        .shadow(radius: 2)
                        .foregroundColor(Color("ModeOpposite"))
                    
                    if (colorScheme == .light) {
                        Image("launchicon")
                            .scaleEffect(self.isAnimating ? 0.2 : 0.3)
                            .colorInvert()
                            .frame(width: 100, height: 100)
                            .onAppear {
                                withAnimation (.linear(duration: 1).repeatForever()) {
                                    self.isAnimating = true
                                }
                            }
                            .onDisappear {
                                self.isAnimating = false
                            }
                    } else {
                        Image("launchicon")
                            .scaleEffect(self.isAnimating ? 0.2 : 0.3)
                            .frame(width: 100, height: 100)
                            .onAppear {
                                withAnimation (.linear(duration: 1).repeatForever()) {
                                    self.isAnimating = false
                                    self.isAnimating = true
                                }
                            }
                            .onDisappear {
                                self.isAnimating = false
                            }
                    }
                    
                    Text("One-Time Disclaimer:")
                        .fontWeight(.bold)
                        .padding(.top)
                    
                    Text("Activities listed in Fort Wayne Scanner are posted by the Fort Wayne Police and Fire Department. All information provided is sourced directly from FWPD and FWFD. Activites are not posted as they happen, but rather as soon as the respective department posts them.")
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
                    viewModel.onboarding = false
                }, label: {
                    ZStack {
                        Capsule()
                            .frame(width: 200, height: 60)
                            .foregroundColor(.blue)
                        
                        Text("Let's Get Scanning")
                            .foregroundColor(.white)
                            .bold()
                    }
                })
                
                Spacer()
                
            }
        }
        .padding()
        .transition(.opacity)
        .onAppear {
            viewModel.locationManager.requestAlwaysAuthorization()
        }
        .onDisappear {
            viewModel.selectedNaturesUD.removeAll()
            viewModel.refreshActivities()
        }
        .frame(maxWidth: 500)
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(viewModel: MainViewModel())
    }
}
