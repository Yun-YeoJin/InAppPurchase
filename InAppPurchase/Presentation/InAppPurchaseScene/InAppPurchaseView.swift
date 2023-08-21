//
//  InAppPurchaseView.swift
//  InAppPurchase
//
//  Created by 윤여진 on 2023/07/13.
//

import UIKit

final class InAppPurchaseView: UIView {
    
    let restoreButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("구매 목록 복원하기", for: .normal)
        btn.setTitleColor(.systemBlue, for: .normal)
        btn.setTitleColor(.blue, for: .highlighted)
        btn.backgroundColor = .systemGray6
        btn.layer.cornerRadius = 10
        return btn
    }()
    
    let listButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("상품 리스트 불러오기", for: .normal)
        btn.setTitleColor(.red, for: .normal)
        btn.setTitleColor(.blue, for: .highlighted)
        btn.backgroundColor = .systemGray6
        btn.layer.cornerRadius = 10
        return btn
    }()
    
    let tableView: UITableView = {
        let tableView  = UITableView(frame: .zero, style: .insetGrouped)
        tableView.allowsSelection = false
        tableView.backgroundColor = .systemGroupedBackground
        tableView.bounces = true
        tableView.showsVerticalScrollIndicator = true
        tableView.contentInset = .zero
        tableView.register(ProductCell.self, forCellReuseIdentifier: ProductCell.id)
        return tableView
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
        
        [restoreButton, listButton, tableView].forEach {
            self.addSubview($0)
        }
        self.backgroundColor = .systemBackground
        
    }
    
    private func setConstraints() {
        
        restoreButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(80)
            make.width.equalTo(200)
        }
        listButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(restoreButton.snp.bottom).offset(40)
            make.width.equalTo(200)
        }
        tableView.snp.makeConstraints { make in
            make.top.equalTo(listButton.snp.bottom).offset(40)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
}

