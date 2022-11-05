//
//  NavBarView.swift
//  Scanner
//
//  Created by Nick Molargik on 9/29/22.
//

import SwiftUI

struct StandardNavBarView: View {
    @Binding var showScanMenu : Bool
    @Binding var showFilter : Bool
    @Binding var showMap : Bool
    @Binding var showCoffee : Bool
    @Binding var showLocationDisclaimer: Bool
    @State var viewModel : MainViewModel
    @AppStorage("scanOn") var scanning = false
    @AppStorage("onboarding") var onboarding = false
    let deviceIdiom = UIScreen.main.traitCollection.userInterfaceIdiom
    
    var body: some View {
        if (deviceIdiom == .phone) {
            VStack {
                Spacer()
                
                HStack (alignment: .center) {
                    Button(action: {
                        let impactMed = UIImpactFeedbackGenerator(style: .medium)
                            impactMed.impactOccurred()
                        withAnimation {
                            showMap.toggle()
                        }
                    }, label: {
                        if (showMap) {
                            Image(systemName: "list.bullet.below.rectangle")
                                .font(.system(size: 25))
                                .foregroundColor(.blue)
                                .shadow(radius: 2)
                        } else {
                            Image(systemName: "map")
                                .font(.system(size: 25))
                                .foregroundColor(.blue)
                                .shadow(radius: 2)
                        }
                    })
                    
                    Spacer()
                    
                    Button(action: {
                        let impactMed = UIImpactFeedbackGenerator(style: .medium)
                            impactMed.impactOccurred()
                        withAnimation {
                            showFilter.toggle()
                        }
                    }, label: {
                        Image(systemName: "camera.filters")
                            .font(.system(size: 25))
                            .shadow(radius: 2)
                    })
                    .disabled(!viewModel.serverResponsive)
                    .foregroundColor(viewModel.serverResponsive ? .green : .gray)
                    
                    Spacer()
                    
                    Text("Scanner")
                        .fontWeight(.black)
                        .italic()
                        .font(.largeTitle)
                        .shadow(radius: 2)
                        .foregroundColor(Color("ModeOpposite"))
                        .onTapGesture {
                            let impactMed = UIImpactFeedbackGenerator(style: .medium)
                                impactMed.impactOccurred()
                            showLocationDisclaimer = true
                        }
                        .onLongPressGesture {
                            onboarding = true
                        }
                        .minimumScaleFactor(0.5)
                    
                    Spacer()
                    
                    Button(action: {
                        let impactMed = UIImpactFeedbackGenerator(style: .medium)
                            impactMed.impactOccurred()
                        withAnimation {
                            showScanMenu.toggle()
                        }
                    }, label: {
                        if (scanning) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 25))
                                .shadow(radius: 2)
                        } else {
                            Image(systemName: "triangle")
                                .font(.system(size: 25))
                                .shadow(radius: 2)
                        }
                    })
                    .disabled(!viewModel.serverResponsive)
                    .foregroundColor(viewModel.serverResponsive ? .red : .gray)
                    
                    Spacer()
                    
                    Button(action: {
                        let impactMed = UIImpactFeedbackGenerator(style: .medium)
                            impactMed.impactOccurred()
                        viewModel.showBookmarks.toggle()
                    }, label: {
                        Image(systemName: viewModel.showBookmarks ? "bookmark.fill" : "bookmark")
                            .font(.system(size: 25))
                            .foregroundColor(.orange)
                            .shadow(radius: 2)
                    }).disabled(viewModel.bookmarkCount == 0)
                        .onChange(of: viewModel.showBookmarks) { _ in
                                if (viewModel.showBookmarks) {
                                    viewModel.getBookmarks()

                                } else {
                                    viewModel.refresh()
                                }
                            }
                }
                .padding([.leading, .trailing])
                
                Spacer()
            }.frame(height: 50)
        } else {
            VStack {
                HStack (alignment: .center) {
                    Button(action: {
                        withAnimation {
                            showFilter.toggle()
                        }
                    }, label: {
                        Image(systemName: "camera.filters")
                            .font(.system(size: 25))
                            .foregroundColor(.green)
                            .shadow(radius: 2)
                    })
                    .disabled(!viewModel.serverResponsive)
                    .opacity(viewModel.serverResponsive ? 1 : 0)
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation {
                            showMap.toggle()
                        }
                    }, label: {
                        if (showMap) {
                            Image(systemName: "list.bullet.below.rectangle")
                                .font(.system(size: 25))
                                .foregroundColor(.blue)
                                .shadow(radius: 2)
                        } else {
                            Image(systemName: "map")
                                .font(.system(size: 25))
                                .foregroundColor(.blue)
                                .shadow(radius: 2)
                        }
                    })
                    .disabled(!viewModel.serverResponsive)
                    .opacity(viewModel.serverResponsive ? 1 : 0)
                    
                    Spacer()
                    
                    Button(action: {
                        showCoffee.toggle()
                    }, label: {
                        Image(systemName: "cup.and.saucer")
                            .font(.system(size: 25))
                            .foregroundColor(.orange)
                            .shadow(radius: 2)
                    })
                    .disabled(!viewModel.serverResponsive)
                    .opacity(viewModel.serverResponsive ? 1 : 0)
                }
                .padding([.leading, .trailing])
                
                Spacer()
            }.frame(height: 50)
        }
    }
}

struct StandardNavBarView_Previews: PreviewProvider {
    static var previews: some View {
        StandardNavBarView(showScanMenu: .constant(false), showFilter: .constant(false), showMap: .constant(false), showCoffee: .constant(false), showLocationDisclaimer: .constant(false), viewModel: MainViewModel())
    }
}
