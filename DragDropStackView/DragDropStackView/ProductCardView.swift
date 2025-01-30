//
//  ProductCard.swift
//  DragDropStackView
//
//  Created by SEKNY YIM on 29/1/25.
//
import UIKit

class ProductCardView: UIView {
    
    lazy private var imageView: UIImageView = {
        let img = UIImageView()
        img.clipsToBounds = true
        img.backgroundColor = .systemGray5
        
        return img
    }()
    
    lazy private var lblTitle: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.textAlignment = .left
        label.textColor = .black
        label.numberOfLines = 1
        return label
    }()
    
    lazy private var lblDescription: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textAlignment = .left
        label.textColor = .systemGray
        label.numberOfLines = 2
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setup()
    }
}

extension ProductCardView {
    func setup() {
        // Setup Image
        addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(8)
            make.bottom.equalToSuperview().inset(16)
            make.top.equalToSuperview().offset(16)
            make.width.equalTo(imageView.snp.height).multipliedBy(1 / 1)
        }
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = imageView.frame.height / 2
        
        // Setup title & description
        let contentView = UIView()
        addSubview(contentView)
        contentView.addSubview(lblTitle)
        contentView.addSubview(lblDescription)
        lblTitle.snp.makeConstraints { make in
            make.leading.top.trailing.equalToSuperview()
        }
        lblDescription.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(lblTitle.snp.bottom).offset(4)
        }
        contentView.snp.makeConstraints { make in
            make.leading.equalTo(imageView.snp.trailing).offset(8)
            make.trailing.equalToSuperview().inset(8)
            make.centerY.equalToSuperview()
        }
    }
    
    func set(_ model: ProductModel) {
        lblTitle.text = model.title ?? ""
        lblDescription.text = model.description ?? ""
        
        guard let images = model.images else { return }
        if let urlString = images[safe: 0],
           let url = URL(string: urlString) {
            imageView.load(url: url)
        }
    }
    
    func set(image: UIImage, title: String, description: String) {
        imageView.image = image
        lblTitle.text = title
        lblDescription.text = description
    }
}
