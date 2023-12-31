//
//  TVStatusView.swift
//  ScannerTV
//
//  Created by Nick Molargik on 10/13/22.
//

import SwiftUI

struct TVStatusView: View {
    @ObservedObject var viewModel : MainViewModel
    @State private var isAnimating = false
    @Environment(\.colorScheme) var colorScheme
    @AppStorage("onboarding") var onboarding = false
    
    var body: some View {
        VStack {
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
                .mask(Circle().frame(width: 345, height: 345).scaleEffect(self.isAnimating ? 0.3 : 0.5))
            } else {
                if (viewModel.serverResponsive) {
                    VStack {
                        ZStack {
                            if (colorScheme == .light) {
                                Image("launchicon")
                                    .scaleEffect(self.isAnimating ? 0.3 : 0.5)
                                    .colorInvert()
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
                                    .scaleEffect(self.isAnimating ? 0.3 : 0.5)
                                    .onAppear {
                                        withAnimation (.linear(duration: 1).repeatForever()) {
                                            self.isAnimating = true
                                        }
                                    }
                                    .onDisappear {
                                        self.isAnimating = false
                                    }
                            }
                        }
                        .frame(width: 200, height: 200)
                        
                        
                        Text("Scanning")
                            .font(.system(size: 40))
                            .italic()
                            .bold()
                    }
                } else {
                    VStack {
                        Text("Scanner Services Unavailable")
                            .font(.system(size: 20))
                            .italic()
                            .bold()
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: true, vertical: false)
                        
                        Text("Click Refresh To Retry")
                            .italic()
                            .bold()
                        
                        ZStack {
                            if (colorScheme == .light) {
                                Image("launchicon")
                                    .colorInvert()
                                    .scaleEffect(0.1)
                                    .mask(Circle().frame(width: 70, height: 70))
                                
                            } else {
                                Image("launchicon")
                                    .scaleEffect(0.1)
                                    .mask(Circle().frame(width: 130, height: 130))
                                
                            }
                            
                            Image(systemName: "circle.slash")
                                .font(.system(size: 120))
                            
                        }.frame(width: 200, height: 100)
                    }
                }
            }
        }
    }
}

struct TVStatusView_Previews: PreviewProvider {
    static var previews: some View {
        TVStatusView(viewModel: MainViewModel())
    }
}
