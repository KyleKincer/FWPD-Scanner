//
//  ScanModeSettingsView.swift
//  Scanner
//
//  Created by Nick Molargik on 10/11/22.
//

import SwiftUI

struct OldNotificationSettingsView: View {
    var viewModel: MainViewModel
    @AppStorage("enableLiveActivities") var live = true
    @AppStorage("scanOn") var scanning = false
    @State var selectAll = true
    @State var selection = Set<String>()
    @Binding var showNotificationSheet : Bool
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    withAnimation {
                        showNotificationSheet.toggle()
                        updateSubscription(viewModel: viewModel, selection: selection)
                    }
                }, label: {
                    HStack {
                        Image(systemName: "arrow.left")
                            .foregroundColor(.red)
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
    }
}


struct OldNotificatonSettingsViewPreviews: PreviewProvider {
    static var previews: some View {
        OldNotificationSettingsView(viewModel: MainViewModel(), showNotificationSheet: .constant(true))
    }
}
