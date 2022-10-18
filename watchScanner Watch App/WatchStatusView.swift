//
//  WatchStatusView.swift
//  Scanner
//
//  Created by Nick Molargik on 10/13/22.
//

import SwiftUI

struct WatchStatusView: View {
    @ObservedObject var viewModel : MainViewModel
    @State private var isAnimating = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack {
            if (viewModel.serverResponsive) {
                ZStack {
                    if (colorScheme == .light) {
                        Image("launchicon")
                            .scaleEffect(self.isAnimating ? 0.1 : 0.2)
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
                            .scaleEffect(self.isAnimating ? 0.1 : 0.2)
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
                .frame(width: 100, height: 100)
                
                Text("Scanning")
            } else {
                VStack {
                    Text("Scanner Services Unavailable")
                        .font(.system(size: 15))
                        .italic()
                        .bold()
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Text("Tap To Refresh")
                        .italic()
                        .bold()
                        .font(.system(size: 15))
                    
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
                            .font(.system(size: 90))
                        
                    }.frame(width: 100, height: 100)
                }
            }
        }
    }
}

struct WatchStatusView_Previews: PreviewProvider {
    static var previews: some View {
        WatchStatusView(viewModel: MainViewModel())
    }
}
