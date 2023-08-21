//
//  InAppPurchaseViewController.swift
//  InAppPurchase
//
//  Created by 윤여진 on 2023/07/12.
//

import UIKit
import SnapKit
import StoreKit

final class InAppPurchaseViewController: UIViewController {
    
    let mainView = InAppPurchaseView()
    
    private var products = [SKProduct]()
    
    override func loadView() {
        super.loadView()
        
        self.view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainView.tableView.dataSource = self
        mainView.tableView.delegate = self
        
        mainView.restoreButton.addTarget(self, action: #selector(restore), for: .touchUpInside)
        mainView.listButton.addTarget(self, action: #selector(callList), for: .touchUpInside)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handlePurchaseNoti(_:)), name: .iapServicePurchaseNotification, object: nil)
        
    }
    
}

extension InAppPurchaseViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ProductCell.id, for: indexPath) as! ProductCell
        let product = products[indexPath.row]
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.locale = product.priceLocale
        let formattedString = numberFormatter.string(from: product.price)
        
        if MyProducts.iapService.isProductPurchased(product.productIdentifier) {
            cell.prepare(name: product.localizedTitle, price: "구입 완료", isPurchased: true)
        } else if MyProducts.iapService.canMakePayments {
            cell.prepare(name: product.localizedTitle, price: "\(formattedString!)", isPurchased: false)
        } else {
            cell.prepare(name: "구입할 수 없음.", price: nil, isPurchased: nil)
        }
        
        cell.buyButtonTapped = { [weak self] in
            self?.showAlert(title: "구매하시겠습니까?", message: "인앱결제테스트", buttonTitle: "구매") { _ in
                MyProducts.iapService.buyProduct(product)
            }
        }
        
        return cell
    }
    
}

extension InAppPurchaseViewController {
    
    @objc private func restore() {
        MyProducts.iapService.restorePurchases()
    }
    
    @objc private func callList() {
        MyProducts.iapService.getProducts { [weak self] success, products in
            guard let self else { return }
            if success, let products = products {
                DispatchQueue.main.async {
                    self.products = products
                    self.mainView.tableView.reloadData()
                }
            }
        }
    }
    @objc private func handlePurchaseNoti(_ notification: Notification) {
        
        DispatchQueue.main.async {
            self.mainView.tableView.reloadData()
        }
        
    }
}

#if canImport(SwiftUI) && DEBUG
import SwiftUI

struct InAppPurchaseViewController_Preview: PreviewProvider {
    static var previews: some View {
        InAppPurchaseViewController().showPreview(.iPhone14Pro)
    }
}
#endif

#if canImport(SwiftUI) && DEBUG
import SwiftUI
extension UIViewController {
    
    private struct Preview: UIViewControllerRepresentable {
        let viewController: UIViewController
        
        func makeUIViewController(context: Context) -> UIViewController {
            return viewController
        }
        
        func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        }
    }
    
    func showPreview(_ deviceType: DeviceType = .iPhone12Pro) -> some View {
        Preview(viewController: self).previewDevice(PreviewDevice(rawValue: deviceType.name()))
    }
}
#endif

enum DeviceType {
    case iPhoneSE2
    case iPhone8
    case iPhone12Pro
    case iPhone12ProMax
    case iPhone14Pro
    case iPhone14ProMax
    
    func name() -> String {
        switch self {
        case .iPhoneSE2:
            return "iPhone SE"
        case .iPhone8:
            return "iPhone 8"
        case .iPhone12Pro:
            return "iPhone 12 Pro"
        case .iPhone12ProMax:
            return "iPhone 12 Pro Max"
        case .iPhone14Pro:
            return "iPhone 14 Pro"
        case .iPhone14ProMax:
            return "iPhone 14 Pro Max"
        }
    }
}
