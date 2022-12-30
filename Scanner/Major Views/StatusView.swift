//
//  StatusView.swift
//  Scanner
//
//  Created by Nick Molargik on 10/13/22.
//

import SwiftUI

struct StatusView: View {
    @ObservedObject var viewModel : MainViewModel
    @State private var isAnimating = false
    @Environment(\.colorScheme) var colorScheme
    @AppStorage("onboarding") var onboarding = false
    
    var body: some View {
        if (onboarding) {
            ZStack {
                if (colorScheme == .light) {
                    Image("launchicon")
                        .scaleEffect(self.isAnimating ? 0.3 : 0.5)
                        .colorInvert()
                        .onAppear {
                            withAnimation (.linear(duration: 1).repeatForever()) {
                                self.isAnimating = false
                                self.isAnimating = true
                            }
                            
                        }
                        .onDisappear {
                            self.isAnimating = false
                        }
                } else {
                    Image("launchicon")
                        .scaleEffect(self.isAnimating ? 0.3 : 0.5)
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
            }
            .frame(width: 200, height: 200)
        } else {
            if (!viewModel.serverResponsive) {
                VStack {
                    Text("Scanner Services Unavailable")
                        .font(.system(size: 20))
                        .italic()
                        .bold()
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: true, vertical: false)
                    
                    Text("Check for an App Update\nor Tap To Refresh")
                        .italic()
                        .bold()
                        .multilineTextAlignment(.center)
                    
                    ZStack {
                        if (colorScheme == .light) {
                            Image("launchicon")
                                .colorInvert()
                                .scaleEffect(0.1)
                            
                        } else {
                            Image("launchicon")
                                .scaleEffect(0.1)
                            
                        }
                        
                        Image(systemName: "circle.slash")
                            .font(.system(size: 90))
                        
                    }.frame(width: 200, height: 100)
                }
            }
        }
    }
}

struct StatusView_Previews: PreviewProvider {
    static var previews: some View {
        StatusView(viewModel: MainViewModel())
    }
}
