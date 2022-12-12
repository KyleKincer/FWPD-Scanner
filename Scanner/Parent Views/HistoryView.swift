//
//  HistoryView.swift
//  Scanner
//
//  Created by Nick Molargik on 12/9/22.
//

import SwiftUI

struct HistoryView: View {
    @ObservedObject var viewModel : MainViewModel
    
    var body: some View {
        VStack {
            if (viewModel.history.count > 0) {
                NavigationView {
                    
                    List(viewModel.history.reversed(), id: \.self) { activity in
                        ActivityRowView(activity: activity, viewModel: viewModel)
                    }
                    .navigationTitle("History")
                }
            } else {
                Text("No History In This Session")
                    .bold()
                    .italic()
                
                Image(systemName: "clock.badge.questionmark.fill")
                    .font(.system(size: 40))
                    .padding()
            }
        }
    }
}

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView(viewModel: MainViewModel())
    }
}
