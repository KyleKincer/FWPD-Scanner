//
//  TVNavBarView.swift
//  ScannerTV
//
//  Created by Nick Molargik on 10/12/22.
//

import SwiftUI

struct TVNavBarView: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var showMap : Bool
    @Binding var showLocationDisclaimer: Bool
    @ObservedObject var viewModel : MainViewModel
    @AppStorage("scanOn") var scanning = false
    @AppStorage("onboarding") var onboarding = false
    
    let deviceIdiom = UIScreen.main.traitCollection.userInterfaceIdiom
    
    var body: some View {
        HStack (alignment: .center) {
            
            Button (action: {
                showLocationDisclaimer = true
            }, label: {
                Text("Scanner")
                    .fontWeight(.black)
                    .italic()
                    .font(.largeTitle)
                    .shadow(radius: 2)
                    .lineLimit(1)
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                    .fixedSize(horizontal: true, vertical: true)
            })
            
            Spacer()
            
            Button(action: {
                withAnimation (.linear) {
                    if (showMap) {
                        withAnimation (.linear) {
                            showMap = false
                        }
                    } else {
                        withAnimation (.linear) {
                            showMap = true
                        }
                    }
                }
            }, label: {
                
                ZStack {
                    HStack {
                        if (showMap) {
                            Image(systemName: "list.bullet.below.rectangle")
                                .font(.system(size: 40))
                                .foregroundColor(.blue)
                                .transition(.opacity)
                            
                            Text("Show List")
                                .foregroundColor(.black)
                                .transition(.opacity)
                            
                        } else {
                            Image(systemName: "map")
                                .font(.system(size: 40))
                                .foregroundColor(.blue)
                                .transition(.opacity)
                            
                            Text("Map View")
                                .foregroundColor(.black)
                                .transition(.opacity)
                        }
                    }
                }
            })
            .frame(width: 400)
            .padding(.trailing, 40)
            
            Button(action: {
                withAnimation (.linear) {
                    if (!viewModel.serverResponsive) {
                        withAnimation (.linear(duration: 0.5)) {
                            viewModel.serverResponsive = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                viewModel.serverResponsive = false
                                viewModel.refresh()
                            }
                        }
                    } else {
                        viewModel.refresh()
                    }
                }
            }, label: {
                
                ZStack {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 40))
                            .foregroundColor(.yellow)
                            .transition(.opacity)
                        
                        Text("Refresh")
                            .foregroundColor(.black)
                            .transition(.opacity)
                    }
                }
            })
            .frame(width: 400)
            
        }
        .padding(30)
        
        Spacer()
        
    }
}

struct TVNavBarView_Previews: PreviewProvider {
    static var previews: some View {
        TVNavBarView(showMap: .constant(false), showLocationDisclaimer: .constant(false), viewModel: MainViewModel())
    }
}
