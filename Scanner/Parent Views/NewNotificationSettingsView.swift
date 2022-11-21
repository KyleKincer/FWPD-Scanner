//
//  ScanModeSettingsView.swift
//  Scanner
//
//  Created by Nick Molargik on 10/11/22.
//

import SwiftUI

@available(iOS 16.1, *)
struct NewNotificationSettingsView: View {
    var viewModel: MainViewModel
    @Environment(\.horizontalSizeClass) var sizeClass
    @AppStorage("enableLiveActivities") var live = true
    @AppStorage("scanOn") var scanning = false
    @State var helper = LiveActivityHelper()
    @State var selectAll = true
    @State var selection = Set<String>()
    @State var showScanningInfo = false
    @Binding var showNotificationView : Bool
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    withAnimation {
                        showNotificationView.toggle()
                        updateSubscription(viewModel: viewModel, selection: selection)
                        
                        updateLiveActivitySubscription(viewModel: viewModel)
                    }
                    
                }, label: {
                    HStack {
                        Image(systemName: "arrow.left")
                            .foregroundColor(.red)
                            .bold()
                            .font(.system(size: 30))
                    }
                })
                .padding([.leading, .top])
                
                Spacer()
                
            }
            .padding(.horizontal)
            
            Text("Notifications")
                .fontWeight(.black)
                .italic()
                .font(.largeTitle)
                .shadow(radius: 2)
                .foregroundColor(Color("ModeOpposite"))
            
            if (sizeClass == .compact) {
                HStack {
                    Button(action: {
                        withAnimation {
                            scanning.toggle()
                        }
                        
                        if (scanning) {
                            helper.start()
                        } else {
                            helper.end()
                        }
                    }, label: {
                        ZStack {
                            RoundedRectangle(cornerSize: CGSize(width: 20, height: 20))
                                .foregroundColor(scanning ? .red : .blue)
                                .frame(width: 200, height: 50)
                            
                            Text(scanning ? "Disable Scanning Mode" : "Enable Scanning Mode")
                                .foregroundColor(.white)
                        }
                    })
                    
                    Button(action: {
                        showScanningInfo.toggle()
                    }, label: {
                        Image(systemName: "info.circle")
                            .font(.system(size: 30))
                    })
                    .padding(.leading, 40)
                }
                .padding(.bottom, 20)
            }
            
            Spacer()
            
            
            Text("Filter Notifications By Nature")
                .bold()
                .font(.system(size: 20))
            
            HStack {
                
                Text("Natures")
                    .fontWeight(.semibold)
                    .italic()
                    .padding(.horizontal)

                Button {
                    withAnimation {
                        selection.removeAll()
                    }
                } label: {
                    Text("Clear All")
                }
                .disabled(selection.count == 0)
                .padding(.horizontal)
            }
            .padding()
            
            List(selection: $selection, content: {
                ForEach(viewModel.natures) { nature in
                    Text(nature.name.capitalized)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                }
            })
            .environment(\.editMode, .constant(EditMode.active))
        }
        .interactiveDismissDisabled()
        .alert("Scanning Mode provides the most recent information in the form of a Live Activity widget on the Lock Screen and, where available, the Dynamic Island.", isPresented: $showScanningInfo) {
            Button("OK", role: .cancel) { }
        }
    }
}

@MainActor
func updateSubscription(viewModel: MainViewModel, selection: Set<String>) {
    viewModel.notificationNatures = selection
    
    // Do all the backend stuff
}

@available(iOS 16.1, *)
func updateLiveActivitySubscription(viewModel: MainViewModel) {
    
    // Do more backend stuff
}

@available(iOS 16.1, *)
struct NewNotificatonSettingsViewPreviews: PreviewProvider {
    static var previews: some View {
        NewNotificationSettingsView(viewModel: MainViewModel(), showNotificationView: .constant(true))
    }
}
