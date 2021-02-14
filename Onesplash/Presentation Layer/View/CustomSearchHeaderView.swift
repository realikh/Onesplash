//
//  CustomSearchHeaderView.swift
//  Onesplash
//
//  Created by Мирас on 2/13/21.
//
import SnapKit

class CustomSearchHeaderView: UIView {
    
    @objc var clearButtonPressed: () -> Void = { }
    
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.text = "Recent"
        label.font = .boldSystemFont(ofSize: 24)
        return label
    }()
    
    private let clearButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(clearButtonDidPress), for: .touchUpInside)
        button.setTitle("clear", for: .normal)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureLayout() {
        configureTitleLabel()
        configureClearButton()
    }
    
    private func configureTitleLabel() {
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.left.equalToSuperview().offset(20)
        }
    }
    
    private func configureClearButton() {
        addSubview(clearButton)
        clearButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.right.equalToSuperview().offset(-20)
        }
    }
    
    @objc private func clearButtonDidPress() {
        clearButtonPressed()
    }
}
