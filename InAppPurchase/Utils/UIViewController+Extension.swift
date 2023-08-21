//
//  UIViewController+Extension.swift
//  InAppPurchase
//
//  Created by 윤여진 on 2023/07/17.
//

import UIKit

extension UIViewController {
    
    
    public func showAlert(title: String, message: String, buttonTitle: String, buttonAction: @escaping ((UIAlertAction) -> Void )) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancel = UIAlertAction(title: "취소", style: .cancel)
        let ok = UIAlertAction(title: buttonTitle, style: .default, handler: buttonAction)
        alert.addAction(cancel)
        alert.addAction(ok)
        self.present(alert, animated: true)
        
    }
    
    public func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
}
