//
//  LockScreenView.swift
//  WidgetExtensionExtension
//
//  Created by Nick Molargik on 10/1/22.
//

import SwiftUI

struct LockScreenView: View {
    @State var state: LatestAttribute.ContentState
    
    var body: some View {
        ZStack {
            Color.black
            
            VStack (spacing: 0) {
                TopView(state: state)
                BottomView(state: state)
            }
            .padding(.vertical)
        }
    }
}
