//
//  PurchaseView.swift
//  Scanner
//
//  Created by Nick Molargik on 12/13/22.
//

import SwiftUI
import StoreKit

struct PurchaseView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel : MainViewModel
    
    let productIDs = ["scannerAdRemoval"]
    
    var body: some View {
        VStack {
            Capsule()
                .frame(width: 100, height: 2)
                .padding()
                .foregroundColor(.gray)
            
            Spacer()
            
            Image(systemName: "dollarsign.circle")
                .foregroundColor(.yellow)
                .font(.system(size: 80))
            
            Text("In App Purchase to remove ads. Just to note, ads are currently required to keep services running as our userbase grows. We appreciate any and all support.\n\nThis is a one-time purchase and will be tied to your Scanner account.")
                .padding()
                .multilineTextAlignment(.center)
            
            if (!viewModel.store.myProducts.isEmpty) {
                
                Button(action: {
                    viewModel.store.purchaseProduct(product: viewModel.store.myProducts.first!)
                }, label: {
                    ZStack {
                        Rectangle()
                            .frame(width: 200, height: 50)
                            .cornerRadius(20)
                        
                        Text("Remove Ads: $1.99")
                            .foregroundColor(.white)
                            .fontWeight(.bold)
                        
                    }
                })
            } else {
                Text("No products available at this time.")
                    .fontWeight(.bold)
            }
            
            Button(action: {
                viewModel.store.restoreProducts()
            }, label: {
                Text("Restore Purchases")
                    .foregroundColor(.blue)
            })
            .padding()
            
            Spacer()
        }
        .onAppear(perform: {
            SKPaymentQueue.default().add(viewModel.store)
            viewModel.store.getProducts(productIDs: productIDs)
        })
        .frame(maxWidth: 500)
    }
}

struct PurchaseView_Previews: PreviewProvider {
    static var previews: some View {
        PurchaseView(viewModel: MainViewModel())
    }
}
