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
    @AppStorage("subToAll") var selectAll = false
    @State var selection = Set<String>()
    @State var showScanningInfo = false
    @State var notifications = SubscriptionManager()
    @Binding var showNotificationView : Bool
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    withAnimation {
                        showNotificationView.toggle()
                        
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
            
//            if (sizeClass == .compact) {
//                HStack {
//
//                    Text("Scanning Mode: Coming Soon")
//                        .bold()
//                    Button(action: {
//                        withAnimation {
//                            scanning.toggle()
//                        }
//
//                        if (scanning) {
//                            helper.start()
//                        } else {
//                            helper.end()
//                        }
//                    }, label: {
//                        ZStack {
//                            RoundedRectangle(cornerSize: CGSize(width: 20, height: 20))
//                                .foregroundColor(scanning ? .red : .blue)
//                                .frame(width: 200, height: 50)
//
//                            Text(scanning ? "Disable Scanning Mode" : "Enable Scanning Mode")
//                                .foregroundColor(.white)
//                        }
//                    })
//
//                    Button(action: {
//                        showScanningInfo.toggle()
//                    }, label: {
//                        Image(systemName: "info.circle")
//                            .font(.system(size: 30))
//                    })
//                    .padding(.leading, 40)
//                }
//                .padding(.vertical, 20)
//            }


            Toggle("Notify Of All Activity", isOn: $selectAll)
                .padding(.horizontal, 50)
                .padding(.vertical)
                .bold()

            if (!selectAll) {
                
                Divider()
                
                HStack {
                    Text("Select Natures:")
                        .bold()
                        .font(.system(size: 15))
                    
                    Spacer()
                    
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
                .padding(.horizontal, 50)
                    
                List(selection: $selection, content: {
                    ForEach(viewModel.natures, id: \.name) { nature in
                        Text(nature.name == "" ? "Unknown" : nature.name.capitalized)
                            .lineLimit(1)
                            .minimumScaleFactor(0.75)
                    }
                })
                .environment(\.editMode, .constant(EditMode.active))
            } else {
                Text("Note: This will result in many notifications. To receive fewer notifications, disable the toggle and select specific activty natures!")
                    .padding()
                    .bold()
                
                Text("To receive no notifications, turn off the toggle and make sure no Natures are selected.")
                    .padding()
                    .bold()
                
                
                Spacer()
            }
        }
        .interactiveDismissDisabled()
//        .alert("Scanning Mode provides the most recent information in the form of a Live Activity widget on the Lock Screen and, where available, the Dynamic Island. Any filtering applied to notifications will apply here as well.", isPresented: $showScanningInfo) {
//            Button("OK", role: .cancel) { }
//        }
        .onChange(of: selectAll, perform: { _ in
            if (!selectAll) {
                
                let selectionArray = viewModel.notificationNaturesUD.components(separatedBy: ", ")
                selection = Set(selectionArray)
                viewModel.notificationNatures = selection
            }
        })
        .onAppear {
            if (viewModel.natures.count == 0) {
                viewModel.getNatures()
            }
            
            if (!selectAll) {
                let selectionArray = viewModel.notificationNaturesUD.components(separatedBy: ", ")
                selection = Set(selectionArray)
                viewModel.notificationNatures = selection
            }
        }
        .onDisappear {
            // Handle subscriptions
            if (!selectAll) {
                notifications.unsubscribeFromAll()
                
                if (viewModel.notificationNatures != selection) {
                    
                    // Subscribe to new natures
                    notifications.subscribeToNatures(natures: Array(selection))
                    
                    // Unsubscribe from removed natures
                    let arraySelection = Array(selection)
                    var removedNatures = [String]()
                    for nature in Array(viewModel.notificationNatures) {
                        if !arraySelection.contains(where: {$0 == nature}) {
                            removedNatures.append(nature)
                        }
                    }
                    notifications.removeNatures(natures: removedNatures)
                    
                    viewModel.notificationNatures = selection
                    viewModel.notificationNaturesString = Array(selection)
                    viewModel.notificationNaturesUD = Array(selection).joined(separator: ", ")
                }
            } else {
                notifications.subscribeToAll()
            }
        }
    }
}

@available(iOS 16.1, *)
struct NewNotificatonSettingsViewPreviews: PreviewProvider {
    static var previews: some View {
        NewNotificationSettingsView(viewModel: MainViewModel(), showNotificationView: .constant(true))
    }
}
