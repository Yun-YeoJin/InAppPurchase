//
//  ProductCell.swift
//  ExInAppPurchase
//
//  Created by 김종권 on 2022/06/04.
//

import UIKit
import SnapKit

final class ProductCell: UITableViewCell {
    
    static let id = "ProductCell"
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    let priceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18)
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    let buyButton: UIButton = {
        let button = UIButton()
        button.setTitle("구매", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.setTitleColor(.blue, for: .highlighted)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var buyButtonTapped: (()->())?
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.buyButton.addTarget(self, action: #selector(buyButtonTap), for: .touchUpInside)
        
        configureUI()
        setConstraints()
        
    }
    
    private func configureUI() {
        [nameLabel, priceLabel, buyButton].forEach {
            self.contentView.addSubview($0)
        }
    }
    
    private func setConstraints() {
        
        nameLabel.snp.makeConstraints { make in
            make.leading.top.equalToSuperview().offset(16)
            make.height.equalTo(24)
        }
        priceLabel.snp.makeConstraints { make in
            make.leading.equalTo(nameLabel.snp.leading)
            make.top.equalTo(nameLabel.snp.bottom).offset(8)
            make.bottom.equalToSuperview().offset(-16)
        }
        
        buyButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(24)
            make.size.equalTo(32)
        }
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.prepare(name: nil, price: nil, isPurchased: false)
    }
    
    func prepare(name: String?, price: String?, isPurchased: Bool?) {
        self.nameLabel.text = name
        self.priceLabel.text = price
        self.buyButton.isHidden = isPurchased ?? true
    }
    
    @objc func buyButtonTap() {
        
        buyButtonTapped?()
        
    }
    
    
}

