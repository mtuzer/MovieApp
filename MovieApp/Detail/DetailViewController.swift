//
//  DetailViewController.swift
//  MovieApp
//
//  Created by Mert Tuzer on 4.06.2021.
//

import UIKit

// MARK: ViewModel to be Presented in Controller
struct MovieDetailViewModel {
    let name: String
    let description: String
    let imageURL: String
    let date: String?
    let vote: String
    
    static func from(movieDetail: MovieDetail) -> MovieDetailViewModel {
        return MovieDetailViewModel(name: movieDetail.title,
                                    description: "  " + movieDetail.description,
                                    imageURL: movieDetail.imageURL,
                                    date: movieDetail.date,
                                    vote: "\(movieDetail.voteCount) ⭐")
    }
}

// MARK: Detail Controller
class DetailViewController: UIViewController {
    
    var detailInteractor: DetailInteractable! {
        didSet {
            detailInteractor.delegate = self
        }
    }
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.backgroundColor = .clear
        label.textColor = .darkGray
        label.font = .systemFont(ofSize: 15)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var descriptionView: UITextView = { // it is better to use a text view since description might be too long
        let descView = UITextView()
        descView.textAlignment = .left
        descView.backgroundColor = .clear
        descView.textColor = .black
        descView.font = .systemFont(ofSize: 12)
        descView.isEditable = false
        descView.textContainer.lineFragmentPadding = 0
        descView.translatesAutoresizingMaskIntoConstraints = false
        return descView
    }()
    
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.backgroundColor = .clear
        label.textColor = .black
        label.font = .systemFont(ofSize: 12)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var voteLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.backgroundColor = .clear
        label.textColor = .systemOrange
        label.font = .boldSystemFont(ofSize: 15)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupViews()
        
        self.detailInteractor.load() // load for the movie detail
    }
    
    // MARK: Setup Views
    fileprivate func setupViews() {
        let imageWidth = UIScreen.main.bounds.width
        view.addSubview(imageView)
        NSLayoutConstraint.activate([imageView.heightAnchor.constraint(equalToConstant: imageWidth * 0.75),
                                     imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                                     imageView.leftAnchor.constraint(equalTo: view.leftAnchor),
                                     imageView.widthAnchor.constraint(equalToConstant: imageWidth)])
        
        view.addSubview(titleLabel)
        NSLayoutConstraint.activate([titleLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -30),
                                     titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 15),
                                     titleLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15)])
        
        view.addSubview(descriptionView)
        NSLayoutConstraint.activate([descriptionView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -30),
                                     descriptionView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 15),
                                     descriptionView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15),
                                     descriptionView.heightAnchor.constraint(equalToConstant: 120)])
        
        view.addSubview(dateLabel)
        NSLayoutConstraint.activate([dateLabel.topAnchor.constraint(equalTo: descriptionView.bottomAnchor, constant: 20),
                                     dateLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15)])
        
        view.addSubview(voteLabel)
        NSLayoutConstraint.activate([voteLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -30),
                                     voteLabel.topAnchor.constraint(equalTo: descriptionView.bottomAnchor, constant: 20)])
    }
}

// MARK: - Response to Detail Interactor Actions
extension DetailViewController: DetailInteractorDelegate {
    func handleOutput(_ output: DetailInteractorOutput) {
        DispatchQueue.main.async {
            switch output {
            case .showMovieDetail(let detail):
                self.imageView.loadImageFromURLString(urlString: detail.imageURL)
                self.titleLabel.text = detail.name
                self.descriptionView.text = detail.description
                self.dateLabel.text = detail.date
                self.voteLabel.text = detail.vote
            case .setTitle(let title):
                self.navigationItem.title = title
            case .setLoading(let isLoading):
                isLoading ? Spinner.shared.startAnimating() : Spinner.shared.stopAnimatimating()
            case .throwErrorMessage(let message):
                self.showError(withMessage: message)
            case .favorited(let isFavorite):
                let image = isFavorite ? UIImage(named: "starFilled")?.withRenderingMode(.alwaysOriginal) : UIImage(named: "star")?.withRenderingMode(.alwaysOriginal)
                let button = UIBarButtonItem(image: image,
                                                   style: .plain,
                                                   target: self,
                                                   action: #selector(self.changeFavorite))
                self.navigationItem.setRightBarButton(button, animated: true)
            }
        }
    }
    
    @objc private func changeFavorite() {
        detailInteractor.setFavorite()
    }
}
