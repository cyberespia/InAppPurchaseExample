//
//  IAPHelper.swift
//  InAppExample
//
//  Created by Italo Henrique Queiroz on 08/02/18.
//  Copyright © 2018 Italo Henrique Queiroz. All rights reserved.
//

import StoreKit

public typealias ProductsRequestHandler = (_ success: Bool, _ products:[SKProduct]?) -> ()

open class IAPHelper: NSObject {
    static let IAPHelperPurchaseNotification = "IAPHelperPurchaseNotification"

    fileprivate let productsIds: Set<String>
    fileprivate var purchasedProductIds = Set<String>()
    fileprivate var productsRequest: SKProductsRequest?
    fileprivate var productsRequestHandler: ProductsRequestHandler?
    
    public init(productsIds: Set<String>) {
        self.productsIds = productsIds
        for productId in self.productsIds {
            let purchased = UserDefaults.standard.bool(forKey: productId)
            if purchased {
              //  purchasedProductIds.insert(productId)
                print("This item was purchased >>>" + productId)
            } else {
                print("Not Purchased <<<" + productId)
            }
        }
        
        super.init()
        SKPaymentQueue.default().add(self)
    }
}

extension IAPHelper {
    
    public func requestProducts(completionHandler: @escaping ProductsRequestHandler) {
        self.productsRequest?.cancel()
        self.productsRequestHandler = completionHandler
        
        self.productsRequest = SKProductsRequest(productIdentifiers: self.productsIds)
        self.productsRequest?.delegate = self
        self.productsRequest?.start()
    }
    
    public func buyProduct(_ product: SKProduct){
        print("buying this product \(product.productIdentifier)")
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
    
    public func isProductPurchased(_ productIdentifier: String) -> Bool {
        return purchasedProductIds.contains(productIdentifier)
    }
    
    public class func canMakePayments() -> Bool {
        return SKPaymentQueue.canMakePayments()
    }
    
    public func restorePurchases() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    
}


extension IAPHelper: SKPaymentTransactionObserver {
    
    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                complete(transaction: transaction)
                break
            case .failed:
                fail(transaction: transaction)
                break
            case .restored:
                restore(transaction: transaction)
                break
            case .deferred:
                break
            case .purchasing:
                break
            }
        }
    }
    
    private func complete(transaction: SKPaymentTransaction){
        print("complete")
        deliverPurchaseNotification(identifier: transaction.payment.productIdentifier)
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    private func fail(transaction: SKPaymentTransaction){
        print("Failt")
        if let transactionError = transaction.error as NSError? {
            if transactionError.code != SKError.paymentCancelled.rawValue {
                print("transactionError")
            }
        }
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    private func restore(transaction: SKPaymentTransaction){
        guard let productIdentifier = transaction.original?.payment.productIdentifier else {return}
        print("restore")
        deliverPurchaseNotification(identifier: productIdentifier)
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    private func deliverPurchaseNotification(identifier: String?){
        guard let identifier = identifier else {return}
        if identifier == "TirarAds" {
            purchasedProductIds.insert(identifier)
            UserDefaults.standard.set(true, forKey: identifier)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: IAPHelper.IAPHelperPurchaseNotification), object: identifier)
        }
    }
}

extension IAPHelper: SKProductsRequestDelegate {
    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        let products = response.products
        print("Products Chegaram...")
        self.productsRequestHandler?(true, products)
        self.clearRequestAndHandler()
        
        for p in products {
            print("Found product: \(p.productIdentifier) \(p.localizedTitle) \(p.price.floatValue)")
        }
    }
    
    public func request(_ request: SKRequest, didFailWithError error: Error) {
        print("Fail...")
        self.productsRequestHandler?(false,nil)
        self.clearRequestAndHandler()
    }
    
    func clearRequestAndHandler(){
        self.productsRequest = nil
        self.productsRequestHandler = nil
    }
    
}

