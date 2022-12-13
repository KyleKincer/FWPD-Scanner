//
//  StoreManager.swift
//  Scanner
//
//  Created by Nick Molargik on 12/13/22.
//

import Foundation
import SwiftUI
import StoreKit

class StoreManager: NSObject, ObservableObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    @Published var myProducts = [SKProduct]()
    @Published var transactionState: SKPaymentTransactionState?
    var request: SKProductsRequest!
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        print("S -- Got products")
        
        if (!response.products.isEmpty) {
            for fetchedProduct in response.products {
                DispatchQueue.main.async {
                    self.myProducts.append(fetchedProduct)
                }
            }
        }
        
        for invalidIdentifier in response.invalidProductIdentifiers {
            print("Invalid identifiers found: \(invalidIdentifier)")
        }
    }
    
    func getProducts(productIDs: [String]) {
        print("S -- Requesting Products...")
        let request = SKProductsRequest(productIdentifiers: Set(productIDs))
        request.delegate = self
        request.start()
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        print("S -- Request did fail: \(error)")
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
                switch transaction.transactionState {
                case .purchasing:
                    transactionState = .purchasing
                case .purchased:
                    transactionState = .purchased
                case .restored:
                    transactionState = .restored
                case .failed, .deferred:
                    transactionState = .failed
                default:
                    queue.finishTransaction(transaction)
                }
            }
    }
    
    func purchaseProduct(product: SKProduct) {
        if SKPaymentQueue.canMakePayments() {
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(payment)
            
            // update firebase and user defaults
            
        } else {
            print("S -- User can't make payment")
        }
    }
    
    func restoreProducts() {
        print("S -- Restoring Products")
        SKPaymentQueue.default().restoreCompletedTransactions()
        
        // Get status from firebase and shove it in user defaults
    }
}
