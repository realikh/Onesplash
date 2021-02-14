//
//  UsersCustomCell.swift
//  Onesplash
//
//  Created by Мирас on 2/12/21.
//

import UIKit

class UsersCustomCell: UICollectionViewCell {
    
    var userImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 30
        imageView.clipsToBounds = true
        return imageView
    }()
    
    var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .boldSystemFont(ofSize: 16)
        return label
    }()
    
    var userNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .boldSystemFont(ofSize: 16)
        return label
    }()
    
    var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureLayout() {
        configureUserImageView()
        configureNameLabel()
        configureUserNameLabel()
        configureStackView()
    }
    
    private func configureUserImageView() {
        contentView.addSubview(userImageView)
        userImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.left.equalToSuperview().offset(20)
        }
    }
    
    private func configureNameLabel() {
        stackView.addArrangedSubview(nameLabel)
    }
    
    
    private func configureUserNameLabel() {
        stackView.addArrangedSubview(userNameLabel)
    }
    
    private func configureStackView() {
        contentView.addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.left.equalTo(userImageView.snp.right).offset(20)
        }
    }
}
