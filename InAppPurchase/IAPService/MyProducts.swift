//
//  MyProducts.swift
//  InAppPurchase
//
//  Created by 윤여진 on 2023/07/12.
//

import Foundation

enum MyProducts {
    
    static let productID = "IAP20230713"
    static let productID_2 = "IAP20230714"
    static let productID_3 = "IAP20230715"
    static let productID_4 = "IAP20230716"
    static let productID_5 = "IAP20230717"
    static let iapService: IAPServiceType = IAPService(productIDs: Set<String>([productID, productID_2, productID_3, productID_4, productID_5]))
    
}
 
