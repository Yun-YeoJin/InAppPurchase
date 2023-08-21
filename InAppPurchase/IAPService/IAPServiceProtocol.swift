//
//  IAPServiceProtocol.swift
//  InAppPurchase
//
//  Created by 윤여진 on 2023/07/13.
//

import StoreKit

protocol IAPServiceType {
    var canMakePayments: Bool { get }
    
    func getProducts(completion: @escaping ProductsRequestCompletion)
    func buyProduct(_ product: SKProduct)
    func isProductPurchased(_ productID: String) -> Bool
    func restorePurchases()
}
