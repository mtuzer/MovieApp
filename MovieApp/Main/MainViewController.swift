//
//  MainViewController.swift
//  MovieApp
//
//  Created by Mert Tuzer on 3.06.2021.
//

import UIKit

// MARK: ViewModel to be Presented in Controller
struct MovieViewModel {
    let id: Int
    let name: String
    let imageURL: String
    let isFavorite: Bool
    
    static func from(movie: Movie) -> MovieViewModel {
        return MovieViewModel(id: movie.id,
                              name: movie.title,
                              imageURL: movie.imageURL,
                              isFavorite: UserDefaults.standard.bool(forKey: "\(movie.id)"))
    }
}

// MARK: Main Controller
class MainViewController: UIViewController {
    
    var mainInteractor: MainInteractable! {
        didSet {
            mainInteractor.delegate = self
        }
    }
    
    private var movieViewModels = [MovieViewModel]()
    
    private lazy var searchBar: UISearchBar = {
        let bar = UISearchBar()
        bar.autocorrectionType = .no
        bar.placeholder = "Search for movies.."
        bar.translatesAutoresizingMaskIntoConstraints = false
        bar.barTintColor = .black
        bar.tintColor = .red
        bar.searchTextField.backgroundColor = .white
        bar.showsCancelButton = true
        bar.searchTextField.returnKeyType = .done
        return bar
    }()
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 20
        
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.backgroundColor = .black.withAlphaComponent(0.05)
        return collection
    }()
    
    private let movieCellId = "movieCellId"
    private let loadMoreViewId = "loadMoreViewId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        hideKeyboardWhenTappedAround()

        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.barTintColor = .black
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        setupSearchBar()
        setupCollectionView()
        
        mainInteractor.load() // load initial content from main interactor
    }
    
    // MARK: Setup Views
    fileprivate func setupSearchBar() {
        searchBar.delegate = self
        view.addSubview(searchBar)
        NSLayoutConstraint.activate([searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                                     searchBar.leftAnchor.constraint(equalTo: view.leftAnchor),
                                     searchBar.rightAnchor.constraint(equalTo: view.rightAnchor),
                                     searchBar.heightAnchor.constraint(equalToConstant: 60)])
    }
    
    fileprivate func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(MovieCell.self, forCellWithReuseIdentifier: movieCellId)
        collectionView.register(LoadMoreView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                                withReuseIdentifier: loadMoreViewId)
        
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 0),
                                     collectionView.leftAnchor.constraint(equalTo: view.leftAnchor),
                                     collectionView.rightAnchor.constraint(equalTo: view.rightAnchor),
                                     collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)])
    }
}

// MARK: - Response to Interactor Actions
extension MainViewController: MainInteractorDelegate {
    func navigateToMovieDetail(withId id: Int) {
        let service = MovieNetworkClient()
        let detailInteractor = DetailInteractor(movieId: id, service: service)
        if let interactor = mainInteractor as?  MovieFavoriteDelegate {
            detailInteractor.movieDelegate = interactor
        }
        
        let detailViewController = DetailViewController()
        detailViewController.detailInteractor = detailInteractor
        navigationController?.pushViewController(detailViewController, animated: true)
    }
    
    func handleOutput(_ output: MainInteractorOutput) {
        DispatchQueue.main.async {
            switch output {
            case .showMovies(let models):
                self.movieViewModels = models
                self.collectionView.reloadData()
            case .setLoading(let isLoading):
                isLoading ? Spinner.shared.startAnimating() : Spinner.shared.stopAnimatimating()
                self.view.isUserInteractionEnabled = !isLoading
            case .setTitle(let title):
                self.navigationItem.title = title
            case .throwErrorMessage(let message):
                self.showError(withMessage: message)
            case .refreshFavorites(let tuple):
                self.movieViewModels = tuple.0
                let indexPath = IndexPath(row: tuple.1, section: 0)//IndexPath(item: index, section: 0)
                self.collectionView.reloadItems(at: [indexPath])
            }
        }
    }
}

extension MainViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        movieViewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: movieCellId,
                                                            for: indexPath) as? MovieCell
        else {
            return UICollectionViewCell()
        }
        
        let movieViewModel = movieViewModels[indexPath.row]
        
        cell.imageURL = movieViewModel.imageURL
        cell.titleLabel.text = movieViewModel.name
        cell.starImageView.isHidden = !movieViewModel.isFavorite
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = UIScreen.main.bounds.width / 2 - 20
        let height = width * 1.5
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForFooterInSection section: Int) -> CGSize {
        if collectionView.numberOfItems(inSection: section) == 0 { return .zero }
        let width = UIScreen.main.bounds.width
        let height: CGFloat = 60
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        mainInteractor.movieSelected(atIndex: indexPath.row)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        guard let footer = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: loadMoreViewId, for: indexPath) as? LoadMoreView else {
            return UICollectionReusableView()
        }
        
        footer.button.addTarget(self, action: #selector(loadMoreTapped), for: .touchUpInside)
        return footer
    }
    
    @objc private func loadMoreTapped() {
        searchBar.text = ""
        mainInteractor.loadMoreTapped()
    }
}

extension MainViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        mainInteractor.searchMovie(withTitle: searchText.trimmingCharacters(in: .whitespacesAndNewlines))
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        mainInteractor.searchMovie(withTitle: "")
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        dismissKeyboard()
    }
}
