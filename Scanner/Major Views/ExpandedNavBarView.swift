//
//  ExpandedNavBarView.swift
//  Scanner
//
//  Created by Nick Molargik on 10/11/22.
//

import SwiftUI

struct ExpandedNavBarView: View {
    @Binding var showFilter : Bool
    @Binding var showMap : Bool
    @Binding var showLocationDisclaimer: Bool
    @Binding var showNotificationView : Bool
    @State var viewModel : MainViewModel
    @AppStorage("scanOn") var scanning = false
    @AppStorage("onboarding") var onboarding = false
    let deviceIdiom = UIScreen.main.traitCollection.userInterfaceIdiom
    
    var body: some View {
        HStack (alignment: .center) {
            Text("Scanner")
                .fontWeight(.black)
                .italic()
                .font(.largeTitle)
                .shadow(radius: 2)
                .foregroundColor(Color("ModeOpposite"))
                .onTapGesture {
                    showLocationDisclaimer = true
                }
            
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
                                .font(.system(size: 25))
                                .foregroundColor(.blue)
                                .transition(.opacity)
                            
                            Text("List")
                                .foregroundColor(.primary)
                                .transition(.opacity)
                            
                        } else {
                            Image(systemName: "map")
                                .font(.system(size: 25))
                                .foregroundColor(.blue)
                                .transition(.opacity)
                            
                            Text("Map")
                                .foregroundColor(.primary)
                                .transition(.opacity)
                        }
                    }
                }
            })
            .frame(width: 100, height: 35)
            .background(RoundedRectangle(cornerRadius: 20)
                .stroke(style: StrokeStyle(lineWidth: 2)).foregroundColor(.blue))
            .padding(.horizontal)
            
            if #available(macCatalyst 11.0, *) {
                Button(action: {
                    withAnimation (.linear) {
                        if (showFilter) {
                            withAnimation (.linear) {
                                showFilter = false
                            }
                        } else {
                            withAnimation (.linear) {
                                showFilter = true
                            }
                        }
                        
                    }
                }, label: {
                    ZStack {
                        HStack {
                            Image(systemName: "gear")
                                .font(.system(size: 25))
                                .foregroundColor(.green)
                                .transition(.opacity)
                            
                            Text("Settings")
                                .foregroundColor(.primary)
                                .transition(.opacity)
                                
                        }
                    }
                })
                .frame(width: 115, height: 35)
                .background(RoundedRectangle(cornerRadius: 20)
                    .stroke(style: StrokeStyle(lineWidth: 2)).foregroundColor(.green))
                .padding(.horizontal)
                
            }
            
            Button(action: {
                withAnimation {
                    viewModel.showBookmarks.toggle()
                }
            }, label: {
                Image(systemName: viewModel.showBookmarks ? "bookmark.fill" : "bookmark")
                    .font(.system(size: 20))
                    .foregroundColor(.orange)
                    .shadow(radius: 2)
            })
            .frame(width: 50, height: 35)
            .background(RoundedRectangle(cornerRadius: 20)
                .stroke(style: StrokeStyle(lineWidth: 2)).foregroundColor(.orange))
            .shadow(radius: 2)
            .padding(.horizontal)
            
            Button(action: {
                withAnimation {
                    showNotificationView.toggle()
                }
            }, label: {
                Image(systemName: "bell")
                    .font(.system(size: 20))
                    .foregroundColor(.red)
                    .shadow(radius: 2)
            })
            .frame(width: 50, height: 35)
            .background(RoundedRectangle(cornerRadius: 20)
                .stroke(style: StrokeStyle(lineWidth: 2)).foregroundColor(.red))
            .shadow(radius: 2)
            .padding(.horizontal)
        }
        .padding([.leading, .trailing])
        
        Spacer()
        
    }
}

struct ExpandedNavBarView_Previews: PreviewProvider {
    static var previews: some View {
        ExpandedNavBarView(showFilter: .constant(false), showMap: .constant(false), showLocationDisclaimer: .constant(false), showNotificationView: .constant(false), viewModel: MainViewModel())
            .previewDevice(PreviewDevice(rawValue: "iPad Pro (11-inch) (3rd generation)"))
            .previewDisplayName("iPad Pro (11-inch) (3rd generation)")
    }
}
