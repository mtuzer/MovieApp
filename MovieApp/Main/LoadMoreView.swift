//
//  LoadMoreView.swift
//  MovieApp
//
//  Created by Mert Tuzer on 4.06.2021.
//

import UIKit

class LoadMoreView: UICollectionReusableView {
    lazy var button: UIButton = {
        let button = UIButton()
        button.setTitle("Load More", for: .normal)
        button.tintColor = .white
        button.backgroundColor = .black
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        button.layer.cornerRadius = 20
        button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        addSubview(button)
        NSLayoutConstraint.activate([button.centerXAnchor.constraint(equalTo: centerXAnchor),
                                     button.centerYAnchor.constraint(equalTo: centerYAnchor)])
    }
}
