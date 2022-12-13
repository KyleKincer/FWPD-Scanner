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
    @AppStorage("newToNots") var newToNots = true
    @State private var bellJingle = false
    
    
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
                    playHaptic()
                    withAnimation {
                        showFilter.toggle()
                    }
                }, label: {
                    Image(systemName: "switch.2")
                        .font(.system(size: 25))
                        .shadow(radius: 2)
                })
                .foregroundColor(.green)
                
                Spacer()
                
                Text("Scanner")
                    .fontWeight(.black)
                    .italic()
                    .font(.largeTitle)
                    .shadow(radius: 2)
                    .foregroundColor(Color("ModeOpposite"))
                    .onTapGesture {
                        playHaptic()
                        showLocationDisclaimer = true
                    }
                    .minimumScaleFactor(0.5)
                    .onLongPressGesture(perform: {
                        viewModel.onboarding = true
                    })
 
                Spacer()
                
                Button(action: {
                    playHaptic()
                    newToNots = false
                    bellJingle = false
                    withAnimation {
                        showNotificationSheet.toggle()
                    }
                }, label: {
                    if (newToNots) {
                        Image(systemName: "bell")
                            .shadow(radius: 2)
                            .rotationEffect(.degrees(bellJingle ? 5 : -5))
                            .animation(Animation.easeInOut(duration: 0.15).repeatForever(autoreverses: true))
                            .onAppear() {
                                if (newToNots) {
                                    bellJingle = true
                                }
                            }
                    } else {
                        Image(systemName: "bell")
                            .shadow(radius: 2)
                    }
                })
                .font(.system(size: 25))
                .foregroundColor(.red)
                
                Spacer()
                
                Button(action: {
                    playHaptic()
                    withAnimation {
                        showProfileView.toggle()
                        viewModel.getBookmarks()
                    }
                    
                }, label: {
                    if let url = viewModel.currentUser?.profileImageURL {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .frame(width: 30, height: 30)
                                .clipShape(Circle())
                                .shadow(radius: 2)
                                
                        } placeholder: {
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .foregroundColor(.gray)
                                .shadow(radius: 2)
                        }
                        
                    } else {
                        Image(systemName: viewModel.loggedIn ? "person.crop.circle.fill" : "person.crop.circle")
                            .font(.system(size: 25))
                            .foregroundColor(.orange)
                            .shadow(radius: 2)
                    }
                })
            }
            .padding([.leading, .trailing])
            
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
