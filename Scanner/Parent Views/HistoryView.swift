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
            Text("History View")
            Text("Coming Soon")
        }
    }
}

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView(viewModel: MainViewModel())
    }
}
