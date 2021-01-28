//
//  ImageTableViewCell.swift
//  Onesplash
//
//  Created by Alikhan Khassen on 22.01.2021.
//

import SnapKit

class ImageTableViewCell: UITableViewCell {
    
    var cellImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    var userNameLabel: UILabel  = {
        let label = UILabel()
        label.textColor = .white
        label.font = .boldSystemFont(ofSize: 12)
        return label
    }()
    
    private func configureImageView() {
        contentView.addSubview(cellImageView)
        cellImageView.backgroundColor = .link
        
        cellImageView.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.top.equalToSuperview().offset(2)
            $0.right.equalToSuperview()
            $0.bottom.equalToSuperview().offset(2)
        }
    }
    
    private func configureUserNameLabel() {
        cellImageView.addSubview(userNameLabel)
        userNameLabel.snp.makeConstraints {
            $0.left.equalToSuperview().offset(8)
            $0.bottom.equalToSuperview().offset(-8)
            $0.right.equalToSuperview().offset(-8)
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureImageView()
        configureUserNameLabel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
