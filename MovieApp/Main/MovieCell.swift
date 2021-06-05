//
//  MovieCell.swift
//  MovieApp
//
//  Created by Mert Tuzer on 4.06.2021.
//

import UIKit

class MovieCell: UICollectionViewCell {
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.backgroundColor = .darkGray
        label.textColor = .white
        label.font = .systemFont(ofSize: 12)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var imageURL: String! {
        didSet {
            self.imageView.loadImageFromURLString(urlString: imageURL)
        }
    }
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .black
        return imageView
    }()
    
    lazy var starImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "starFilled")
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        layer.cornerRadius = 10
        clipsToBounds = true
        
        setupViews()
    }
    
    public func setupViews() {
        addSubview(imageView)
        addSubview(titleLabel)
        addSubview(starImageView)
        
        NSLayoutConstraint.activate([imageView.heightAnchor.constraint(equalTo: heightAnchor),
                                     imageView.topAnchor.constraint(equalTo: topAnchor),
                                     imageView.leftAnchor.constraint(equalTo: leftAnchor),
                                     imageView.widthAnchor.constraint(equalTo: widthAnchor),
                                     starImageView.rightAnchor.constraint(equalTo: rightAnchor, constant: -10),
                                     starImageView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
                                     starImageView.heightAnchor.constraint(equalToConstant: 20),
                                     starImageView.widthAnchor.constraint(equalToConstant: 20),
                                     titleLabel.leftAnchor.constraint(equalTo: leftAnchor),
                                     titleLabel.rightAnchor.constraint(equalTo: rightAnchor),
                                     titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
                                     titleLabel.heightAnchor.constraint(equalToConstant: 40)])
        
        imageView.clipsToBounds = true
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
