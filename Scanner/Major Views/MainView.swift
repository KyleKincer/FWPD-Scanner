//
//  MainView.swift
//  Scanner
//
//  Created by Nick Molargik on 9/28/22.
//

import SwiftUI

struct MainView: View {
    @Environment(\.horizontalSizeClass) var sizeClass
    @EnvironmentObject private var appDelegate: AppDelegate
    @StateObject var viewModel : MainViewModel
    @AppStorage("showDistance") var showDistance = true
    @State private var showFilter = false
    @State private var showMap = false
    @State private var showNotificationView = false
    @State private var showLocationDisclaimer = false
    @State private var showProfileView = false
    
    var scene: SKScene {
        let scene = SnowScene()
        scene.scaleMode = .resizeFill
        scene.backgroundColor = .clear
        return scene
    }
    
    var body: some View {
        ZStack {
            if (Date().formatted(date: .abbreviated, time: .omitted) == "Dec 25, 2022") {
                SpriteView(scene: scene, options: [.allowsTransparency])
                    .ignoresSafeArea()
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            }
            
            
            if (viewModel.onboarding) {
                OnboardingView(viewModel: viewModel)
                    .transition(.opacity)
                
            } else {
                VStack {
                    if viewModel.showAuthError {
                        alert(viewModel.authError, isPresented: $viewModel.showAuthError, actions: {})
                    }
                    
                    if (sizeClass == .compact) {
                        StandardNavBarView(showNotificationSheet: $showNotificationView, showFilter: $showFilter, showMap: $showMap, showLocationDisclaimer: $showLocationDisclaimer, showProfileView: $showProfileView, viewModel: viewModel)
                            .transition(.opacity)
                        
                        ActivityView(showMap: $showMap, viewModel: viewModel)
                            .environmentObject(appDelegate)
                            .transition(.opacity)
                        
                    } else {
                        VStack {
                            ExpandedNavBarView(showFilter: $showFilter, showMap: $showMap, showLocationDisclaimer: $showLocationDisclaimer, showNotificationView: $showNotificationView, showProfileView: $showProfileView, viewModel: viewModel)
                                .transition(.opacity)
                            
                            Divider()
                                .padding(0)
                            
                            ActivityView(showMap: $showMap, viewModel: viewModel)
                                .environmentObject(appDelegate)
                                .padding(.top, -8)
                                .transition(.opacity)
                            
                            
//                            Divider()
//                                .padding(0)
//                            
//                            SwiftUIBannerAd(adPosition: .bottom, adUnitId: Constants.appID)
//                                .ignoresSafeArea()
//                                .frame(maxHeight: 40)
                            
                        }
                    }
                }
                .onAppear {
                    showDistance = true
                }
                
                .fullScreenCover(isPresented: $showFilter) {
                    FilterSettingsView(showFilter: $showFilter, viewModel: viewModel)
                }
                
                .fullScreenCover(isPresented: $showNotificationView) {
                    NotificationSettingsView(viewModel: viewModel, showNotificationView: $showNotificationView)
                }
                
                .fullScreenCover(isPresented: $showProfileView) {
                    ProfileView(viewModel: viewModel, showProfileView: $showProfileView)
                }
                
                .sheet(isPresented: $showLocationDisclaimer) {
                    if #available(iOS 16.1, *) {
                        DisclaimerView()
                            .presentationDetents([.fraction(0.5)])
                    } else {
                        DisclaimerView()
                    }
                }
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        
        MainView(viewModel: MainViewModel())
            .previewDevice(PreviewDevice(rawValue: "iPhone 13 mini"))
            .previewDisplayName("iPhone 13 mini")
            .environmentObject(AppDelegate())
        
        MainView(viewModel: MainViewModel())
            .previewDevice(PreviewDevice(rawValue: "iPad Pro (11-inch) (3rd generation)"))
            .previewDisplayName("iPad Pro (11-inch) (3rd generation)")
            .environmentObject(AppDelegate())
    }
}

import SpriteKit
class SnowScene: SKScene {

    let snowEmitterNode = SKEmitterNode(fileNamed: "Snow.sks")

    override func didMove(to view: SKView) {
        guard let snowEmitterNode = snowEmitterNode else { return }
        snowEmitterNode.particleSize = CGSize(width: 50, height: 50)
        snowEmitterNode.particleLifetime = 2
        snowEmitterNode.particleLifetimeRange = 6
        addChild(snowEmitterNode)
    }

    override func didChangeSize(_ oldSize: CGSize) {
        guard let snowEmitterNode = snowEmitterNode else { return }
        snowEmitterNode.particlePosition = CGPoint(x: size.width/2, y: size.height)
        snowEmitterNode.particlePositionRange = CGVector(dx: size.width, dy: size.height)
    }
}
