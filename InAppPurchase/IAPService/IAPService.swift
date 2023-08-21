//
//  IAPService.swift
//  InAppPurchase
//
//  Created by 윤여진 on 2023/07/12.
//

import StoreKit
import Foundation

typealias ProductsRequestCompletion = (_ success: Bool, _ products: [SKProduct]?) -> Void

final class IAPService: NSObject, IAPServiceType {
    
    private let productIDs: Set<String>
    private var purchasedProductIDs: Set<String>
    private var productsRequest: SKProductsRequest?
    private var productsCompletion: ProductsRequestCompletion?
    
    //MARK: SKPaymentQueue
    var canMakePayments: Bool {
        SKPaymentQueue.canMakePayments()
    }
    
    init(productIDs: Set<String>) {
        /**
         초기화 시 특정 앱에 대한 모든 상품 ID를 가져오는 메커니즘이 없기 때문에 앱 자체에 ID 리스트가 있어야함
         상품 ID를 받아 저장하고 유저디폴트의 구매 내역을 확인.
         */
        self.productIDs = productIDs
        self.purchasedProductIDs = productIDs.filter { UserDefaults.standard.bool(forKey: $0) == true }
        
        super.init()
        /// App Store와 지불정보를 동기화하기 위한 Observer 추가
        SKPaymentQueue.default().add(self)
    }
    
    /// App Store Connect에서 등록한 인앱결제 상품들을 가져올 때
    func getProducts(completion: @escaping ProductsRequestCompletion) {
        print(#function)
        self.productsRequest?.cancel()
        self.productsCompletion = completion
        self.productsRequest = SKProductsRequest(productIdentifiers: self.productIDs)
        self.productsRequest?.delegate = self
        self.productsRequest?.start()
    }
    
    /// 인앱결제 상품을 구입할 때
    func buyProduct(_ product: SKProduct) {
        print(#function)
        print("""
            [SKProduct]
            productID : \(product.productIdentifier)
            localizedTitle : \(product.localizedTitle)
            localizedDescription : \(product.localizedDescription)
            price : \(product.price)
            priceLocale : \(product.priceLocale)
            contentVersion : \(product.contentVersion)
            subscriptionPeriod : \(String(describing: product.subscriptionPeriod?.numberOfUnits))
            isDownloadable : \(product.isDownloadable)
            """)
        SKPaymentQueue.default().add(SKPayment(product: product))
    }
    
    /// 구입한 상품들을 가져올 때, UserDefaults에 true인 것들과 비교해서 가져옴
    func isProductPurchased(_ productID: String) -> Bool {
        print(#function)
        return self.purchasedProductIDs.contains(productID)
    }
    
    /// 구입 내역을 복원할 때
    func restorePurchases() {
        print(#function)
        for productID in productIDs {
            UserDefaults.standard.set(false, forKey: productID)
        }
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
}
//MARK: SKProductsRequestDelegate
extension IAPService: SKProductsRequestDelegate {
    
    ///인앱결제 상품 리스트를 가져오기.
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        print(#function)
        let products = response.products
        let inValidProduct = response.invalidProductIdentifiers
        print("[SKProductsResponse]")
        print("products ::: \(products)")
        print("inValidProduct ::: \(inValidProduct)")
        self.productsCompletion?(true, products)
        self.clearRequestAndHandler()
        
        products.forEach { print("인앱 결제 상품들 : \($0.productIdentifier) \($0.localizedTitle) \($0.price.floatValue)") }
    }
    
    ///상품 리스트 가져오기 실패할 경우
    func request(_ request: SKRequest, didFailWithError error: Error) {
        print("Error: \(error.localizedDescription)")
        self.productsCompletion?(false, nil)
        self.clearRequestAndHandler()
    }
    
    private func clearRequestAndHandler() {
        self.productsRequest = nil
        self.productsCompletion = nil
    }
}

//MARK: SKPaymentTransactionObserver
///product을 결제 했을때, 결제에 실패했을 경우 App Store응답을 처리하는 Observer
extension IAPService: SKPaymentTransactionObserver {
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        transactions.forEach {
            switch $0.transactionState {
            ///성공적으로 처리된 트랜잭션
            case .purchased:
                print("completed transaction")
                print("""
                    [SKPaymentTransaction]
                    transactionIdentifier : \(String(describing: $0.transactionIdentifier))
                    payment.productIdentifier : \($0.payment.productIdentifier)
                    payment.quantity : \($0.payment.quantity)
                    transactionState : \($0.transactionState.rawValue)
                    error : \(String(describing: $0.error))
                    original : \(String(describing: $0.original))
                    transactionDate : \(String(describing: $0.transactionDate))
                    """)
                complete(transaction: $0)
//                getReceiptData(transaction: $0, productIdentifier: $0.payment.productIdentifier)
                
            ///실패한 트랜잭션
            case .failed:
                print("failed transaction")
                print("""
                    [SKPaymentTransaction]
                    transactionIdentifier : \(String(describing: $0.transactionIdentifier))
                    payment.productIdentifier : \($0.payment.productIdentifier)
                    payment.quantity : \($0.payment.quantity)
                    transactionState : \($0.transactionState.rawValue)
                    error : \(String(describing: $0.error))
                    original : \(String(describing: $0.original))
                    transactionDate : \(String(describing: $0.transactionDate))
                    """)
                fail(transaction: $0)
                
            ///사용자가 이전에 구매한 콘텐츠를 복원하는 트랜잭션
            case .restored:
                print("restored transaction")
                print("""
                    [SKPaymentTransaction]
                    transactionIdentifier : \(String(describing: $0.transactionIdentifier))
                    payment.productIdentifier : \($0.payment.productIdentifier)
                    payment.quantity : \($0.payment.quantity)
                    transactionState : \($0.transactionState.rawValue)
                    error : \(String(describing: $0.error?.localizedDescription))
                    original : \(String(describing: $0.original))
                    transactionDate : \(String(describing: $0.transactionDate))
                    """)
                restore(transaction: $0)

            ///대기열에 있지만 최종 상태가 구매 요청과 같은 외부 작업 보류 중인 트랜잭션
            case .deferred:
                print("deferred")
                
            ////App Store에서 처리중인 트랜잭션
            case .purchasing:
                print("purchasing")
                print("""
                    [SKPaymentTransaction]
                    transactionIdentifier : \(String(describing: $0.transactionIdentifier))
                    payment.productIdentifier : \($0.payment.productIdentifier)
                    payment.quantity : \($0.payment.quantity)
                    transactionState : \($0.transactionState.rawValue)
                    error : \(String(describing: $0.error))
                    original : \(String(describing: $0.original))
                    transactionDate : \(String(describing: $0.transactionDate))
                    """)
                
            default:
                print("unknown")
            }
        }
    }
    
    /// 구입 성공
    private func complete(transaction: SKPaymentTransaction) {
        print(#function)
        deliverPurchaseNotificationFor(identifier: transaction.payment.productIdentifier)
        //거래 내역(transaction)을 큐에서 제거
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    /// 복원 성공
    private func restore(transaction: SKPaymentTransaction) {
        print(#function)
        guard let productIdentifier = transaction.original?.payment.productIdentifier else { return }
        deliverPurchaseNotificationFor(identifier: productIdentifier)
        //거래 내역(transaction)을 큐에서 제거
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    /// 구매 실패
    private func fail(transaction: SKPaymentTransaction) {
        if let transactionError = transaction.error as NSError?,
           let localizedDescription = transaction.error?.localizedDescription,
           transactionError.code != SKError.paymentCancelled.rawValue {
            print("Transaction Error: \(localizedDescription)")
        }
        //거래 내역(transaction)을 큐에서 제거
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    /// 구매한 인앱 상품 키에 대한 UserDefaults Bool 값을 변경
    private func deliverPurchaseNotificationFor(identifier: String?) {
        guard let identifier = identifier else { return }
        self.purchasedProductIDs.insert(identifier)
        UserDefaults.standard.set(true, forKey: identifier)
        NotificationCenter.default.post(name: .iapServicePurchaseNotification, object: identifier)
    }
}

extension IAPService {
    
    /// 구매이력 영수증 가져오기 - 검증용
    public func getReceiptData(transaction: SKPaymentTransaction, productIdentifier: String) {
        
        let receiptFileURL = Bundle.main.appStoreReceiptURL
        let receiptData = try? Data(contentsOf: receiptFileURL!)
        let receiptString = receiptData?.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
        
        print(receiptString!)
        
        //거래 내역(transaction)을 큐에서 제거
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    
}
