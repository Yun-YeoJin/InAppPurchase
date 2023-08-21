//
//  MainView.swift
//  InAppPurchase
//
//  Created by 윤여진 on 2023/07/13.
//

import UIKit

final class MainView: UIView {
    
    let btn: UIButton = {
        let btn = UIButton()
        btn.setTitle("인앱결제 하러가기", for: .normal)
        btn.setTitleColor(.red, for: .normal)
        btn.layer.cornerRadius = 8
        btn.layer.borderColor = UIColor.blue.cgColor
        return btn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        
        [btn].forEach {
            self.addSubview($0)
        }
        self.backgroundColor = .systemBackground
        
    }
    
    private func setConstraints() {
        
        btn.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
    }
    
}
