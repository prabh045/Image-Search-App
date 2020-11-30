//
//  IndicatorReusableView.swift
//  ImageSearch
//
//  Created by Prabhdeep Singh on 30/11/20.
//  Copyright © 2020 Prabh. All rights reserved.
//

import UIKit

class IndicatorReusableView: UICollectionReusableView {
    
    static let identifier = "IndicatorView"
    lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var indicatorView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        view.startAnimating()
        view.color = .red
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(containerView)
        containerView.addSubview(indicatorView)
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            containerView.topAnchor.constraint(equalTo: self.topAnchor),
            containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
            indicatorView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            indicatorView.topAnchor.constraint(equalTo: containerView.topAnchor),
            indicatorView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),           indicatorView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            
        ])
    }
    
    
    
}
