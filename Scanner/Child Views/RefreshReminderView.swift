//
//  RefreshReminderView.swift
//  Scanner
//
//  Created by Nick Molargik on 11/20/22.
//

import SwiftUI

struct RefreshReminderView: View {
    @ObservedObject var viewModel : MainViewModel
    @Binding var showingRefreshReminder : Bool
    @State var startingOffsetY: CGFloat = 45.0
    @State var currentDragOffsetY: CGFloat = 0
    
    var body: some View {
        VStack {
            Button() {
                withAnimation {
                    playHaptic()
                    viewModel.refresh()
                }
                withAnimation(.spring()) {
                    showingRefreshReminder.toggle()
                }
            } label: {
                ZStack{
                    RoundedRectangle(cornerRadius: 15)
                    HStack {
                        Text("Refresh").fontWeight(.semibold)
                        Image(systemName: "arrow.clockwise")
                    }
                    .tint(.white)
                }
                .frame(width: 120, height: 33)
                .padding(.bottom)
            }
            .offset(y: startingOffsetY)
            .offset(y: currentDragOffsetY)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        currentDragOffsetY = value.translation.height
                    }
                    .onEnded{ value in
                        if value.translation.height < 0 {
                            withAnimation(.spring()) {showingRefreshReminder = false}
                        }
                    }
            )
            
            Spacer()
            
        }
        .transition(.move(edge: .top))
    }
}

struct RefreshReminderView_Previews: PreviewProvider {
    static var previews: some View {
        RefreshReminderView(viewModel: MainViewModel(), showingRefreshReminder: .constant(true))
    }
}
