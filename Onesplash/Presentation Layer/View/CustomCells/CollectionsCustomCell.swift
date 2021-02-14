//
//  CollectionsCustomCell.swift
//  Onesplash
//
//  Created by Мирас on 2/12/21.
//

import SnapKit

class CollectionsCustomCell: UICollectionViewCell {
    
    var collectionImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    var collectionNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .boldSystemFont(ofSize: 24)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.cornerRadius = 25.0
        self.contentView.layer.borderWidth = 1.0
        self.contentView.layer.borderColor = UIColor.clear.cgColor
        self.contentView.layer.masksToBounds = true
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureLayout() {
        configureCollectionImageView()
        configureCollectionNameLabel()
    }
    
    private func configureCollectionImageView() {
        contentView.addSubview(collectionImageView)
        collectionImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    private func configureCollectionNameLabel() {
        contentView.addSubview(collectionNameLabel)
        collectionNameLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
    }
    
}
