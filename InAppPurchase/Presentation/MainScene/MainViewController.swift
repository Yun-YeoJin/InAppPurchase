//
//  MainViewController.swift
//  InAppPurchase
//
//  Created by 윤여진 on 2023/07/12.
//

import UIKit

final class MainViewController: UIViewController {

    let mainView = MainView()
    
    override func loadView() {
        self.view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        navigationItem.title = "인앱결제테스트"
        navigationController?.navigationBar.backgroundColor = .lightGray
        
        mainView.btn.addTarget(self, action: #selector(goToIAPViewController), for: .touchUpInside)
    }
    
    @objc func goToIAPViewController() {
        
        let vc = InAppPurchaseViewController()
        vc.modalPresentationStyle = .formSheet
        self.present(vc, animated: true)
        
    }
    
}


