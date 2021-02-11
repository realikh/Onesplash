//
//  FooterCollectionReusableView.swift
//  Onesplash
//
//  Created by Alikhan Khassen on 10.02.2021.
//

import UIKit

class FooterCollectionReusableView: UICollectionReusableView {
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        return indicator
    }()
    
    func configure() {
        addSubview(activityIndicator)
        activityIndicator.startAnimating()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        activityIndicator.frame = bounds
    }
}
