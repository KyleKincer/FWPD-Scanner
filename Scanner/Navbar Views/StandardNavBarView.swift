//
//  NavBarView.swift
//  Scanner
//
//  Created by Nick Molargik on 9/29/22.
//

import SwiftUI

struct StandardNavBarView: View {
    @Binding var showNotificationSheet : Bool
    @Binding var showFilter : Bool
    @Binding var showMap : Bool
    @Binding var showLocationDisclaimer: Bool
    @Binding var showProfileView : Bool
    @State var viewModel : MainViewModel
    @AppStorage("scanOn") var scanning = false
    @AppStorage("onboarding") var onboarding = false
    @State private var allJingle = false
    
    
    @Environment(\.horizontalSizeClass) var sizeClass
    
    let deviceIdiom = UIScreen.main.traitCollection.userInterfaceIdiom
    
    var body: some View {
        VStack {
            Spacer()
            
            HStack (alignment: .center) {
                Button(action: {
                    playHaptic()
                    withAnimation {
                        showMap.toggle()
                    }
                }, label: {
                    if (showMap) {
                        if (Date().formatted(date: .abbreviated, time: .omitted) == "Dec 25, 2022") {
                            Image(systemName: "list.bullet.below.rectangle")
                                .shadow(radius: 2)
                                .font(.system(size: 25))
                                .foregroundColor(.blue)
                                .rotationEffect(.degrees(allJingle ? 5 : -5))
                                .animation(Animation.easeInOut(duration: 0.15).repeatForever(autoreverses: true))
                                .onAppear {
                                    allJingle = true
                                }
                                .onDisappear {
                                    allJingle = false
                                }
                            
                        } else {
                            Image(systemName: "list.bullet.below.rectangle")
                                .font(.system(size: 25))
                                .shadow(radius: 2)
                                .foregroundColor(.blue)
                        }
                    } else {
                        if (Date().formatted(date: .abbreviated, time: .omitted) == "Dec 25, 2022") {
                            Image(systemName: "map")
                                .shadow(radius: 2)
                                .font(.system(size: 25))
                                .foregroundColor(.blue)
                                .rotationEffect(.degrees(allJingle ? 5 : -5))
                                .animation(Animation.easeInOut(duration: 0.15).repeatForever(autoreverses: true))
                                .onAppear {
                                    allJingle = true
                                }
                                .onDisappear {
                                    allJingle = false
                                }
                        } else {
                            Image(systemName: "map")
                                .font(.system(size: 25))
                                .foregroundColor(.blue)
                                .shadow(radius: 2)
                        }
                    }
                })
                .accessibilityLabel("Toggle map view and list view")
                
                Spacer()
                
                Button(action: {
                    playHaptic()
                    withAnimation {
                        showFilter.toggle()
                    }
                }, label: {
                    if (Date().formatted(date: .abbreviated, time: .omitted) == "Dec 25, 2022") {
                        Image(systemName: "switch.2")
                            .shadow(radius: 2)
                            .font(.system(size: 25))
                            .foregroundColor(.green)
                            .rotationEffect(.degrees(allJingle ? 5 : -5))
                            .animation(Animation.easeInOut(duration: 0.15).repeatForever(autoreverses: true))
                            .onAppear {
                                allJingle = true
                            }
                            .onDisappear {
                                allJingle = false
                            }
                    } else {
                        Image(systemName: "switch.2")
                            .font(.system(size: 25))
                            .foregroundColor(.green)
                            .shadow(radius: 2)
                    }
                })
                .foregroundColor(.green)
                .accessibilityLabel("Activity Filters")
                
                Spacer()
                
                Text("Scanner")
                    .fontWeight(.black)
                    .italic()
                    .font(.largeTitle)
                    .shadow(radius: 2)
                    .foregroundColor(Color("ModeOpposite"))
                    .onTapGesture {
                        playHaptic()
                        withAnimation {
                            showLocationDisclaimer = true
                        }
                    }
                    .minimumScaleFactor(0.5)
                    .onLongPressGesture(perform: {
                        playHaptic()
                        withAnimation {
                            viewModel.onboarding = true
                        }
                    })
                    .accessibilityLabel("Scanner header. Tap to view location disclaimer.")
 
                Spacer()
                
                Button(action: {
                    playHaptic()
                    withAnimation {
                        showNotificationSheet.toggle()
                    }
                }, label: {
                    if (Date().formatted(date: .abbreviated, time: .omitted) == "Dec 25, 2022") {
                        Image(systemName: "bell")
                            .shadow(radius: 2)
                            .rotationEffect(.degrees(allJingle ? 5 : -5))
                            .animation(Animation.easeInOut(duration: 0.15).repeatForever(autoreverses: true))
                            .onAppear {
                                allJingle = true
                            }
                                            
                    } else {
                        Image(systemName: "bell")
                            .shadow(radius: 2)
                    }
                })
                .font(.system(size: 25))
                .foregroundColor(.red)
                .accessibilityLabel("Notification Settings")
                
                Spacer()
                
                Button(action: {
                    playHaptic()
                    withAnimation {
                        showProfileView.toggle()
                        viewModel.getBookmarks()
                    }
                    
                }, label: {
                    if (Date().formatted(date: .abbreviated, time: .omitted) == "Dec 25, 2022") {
                        ProfilePhoto(url: viewModel.currentUser?.profileImageURL, size: 80)
                            .font(.system(size: 25))
                            .foregroundColor(.orange)
                            .shadow(radius: 2)
                            .rotationEffect(.degrees(allJingle ? 5 : -5))
                            .animation(Animation.easeInOut(duration: 0.15).repeatForever(autoreverses: true))
                            .scaleEffect(0.35)
                            .frame(width: 40, height: 20)
                    } else {
                        ProfilePhoto(url: viewModel.currentUser?.profileImageURL, size: 80)
                            .scaleEffect(0.35)
                            .frame(width: 40, height: 20)
                    }
                })
            }
            .padding([.leading, .trailing])
            .accessibilityLabel("Profile")
            
            Spacer()
            
        }.frame(height: 50)
    }
            
}

struct StandardNavBarView_Previews: PreviewProvider {
    static var previews: some View {
        StandardNavBarView(showNotificationSheet: .constant(false), showFilter: .constant(false), showMap: .constant(false), showLocationDisclaimer: .constant(false), showProfileView: .constant(false), viewModel: MainViewModel())
    }
}


func playHaptic() {
    let impactMed = UIImpactFeedbackGenerator(style: .medium)
        impactMed.impactOccurred()
}
