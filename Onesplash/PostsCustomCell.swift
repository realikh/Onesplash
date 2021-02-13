//
//  CustomCollectionViewCell.swift
//  Onesplash
//
//  Created by Мирас on 1/29/21.
//

import SnapKit
import ImageViewer_swift

class PostsCustomCell: UICollectionViewCell {
    
    var cellImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    var userNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .boldSystemFont(ofSize: 12)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureLayout() {
        configureImageView()
        configureLabel()
    }
    
    private func configureImageView() {
        contentView.addSubview(cellImageView)
        cellImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    private func configureLabel() {
        contentView.addSubview(userNameLabel)
        userNameLabel.snp.makeConstraints {
            $0.left.equalToSuperview().offset(4)
            $0.bottom.equalToSuperview().offset(4)
            $0.width.equalToSuperview()
            $0.height.equalTo(44)
        }
    }
}
