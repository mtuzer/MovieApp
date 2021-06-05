//
//  DetailInteractor.swift
//  MovieApp
//
//  Created by Mert Tuzer on 4.06.2021.
//

import Foundation

// MARK: Design Necessary Protocols for Interactor
protocol DetailInteractable: AnyObject {
    var delegate: DetailInteractorDelegate? { get set }
    var movieDelegate: MovieFavoriteDelegate? { get set }
    func load()        // initial load to fill screen content
    func setFavorite() // respond to tapping favorite button
}

enum DetailInteractorOutput {
    case showMovieDetail(MovieDetailViewModel) // depending on network request result, give view model
    case setTitle(String)                     // set controller title
    case setLoading(Bool)                     // set loading, with respect to fetching situation
    case throwErrorMessage(String)            // depending on network request result, throw errors
    case favorited(Bool)                      // depending on the bool, set favorite button
}

// MARK: Protocol for Responder to Interactor
protocol DetailInteractorDelegate: AnyObject {
    func handleOutput(_ output: DetailInteractorOutput) // respond depending on outputs
}

// MARK: Protocol for Responder to React Changes in Favorites
protocol MovieFavoriteDelegate: AnyObject {
    func movieFavorited() // notify a change exists in favorite movie
}

// MARK: Detail Interactor
class DetailInteractor: DetailInteractable {
    weak var delegate: DetailInteractorDelegate?
    weak var movieDelegate: MovieFavoriteDelegate?
    
    private let id: Int
    private let service: MovieNetworking
    
    init(movieId id: Int, service: MovieNetworking) {
        self.id = id
        self.service = service
    }
    
    func load() {
        notifyController(.setTitle("Movie Detail"))
        notifyController(.setLoading(true))
        
        let isFavorite = UserDefaults.standard.bool(forKey: "\(id)")
        notifyController(.favorited(isFavorite))
        
        service.getMovieDetail(withId: self.id) { [weak self] result in
            switch result {
            case .success(let detail):
                let movieDetailViewModel = MovieDetailViewModel.from(movieDetail: detail)
                self?.notifyController(.showMovieDetail(movieDetailViewModel))
            case .failure(let error):
                self?.handleError(error: error)
            }
            self?.notifyController(.setLoading(false))
        }
    }
    
    private func handleError(error: MovieNetworkError) {
        var message = "An unknown error occurred."
        switch error {
        case .invalidURL:
            message = "An invalid URL is used to fetch movie Detail."
        case .invalidPayload, .unknownError, .noApiKey:
            break
        }
        
        notifyController(.throwErrorMessage(message))
    }
    
    func setFavorite() {
        let isFavorite = UserDefaults.standard.bool(forKey: "\(id)")
        
        if isFavorite {
            UserDefaults.standard.set(false, forKey: "\(id)")
        } else {
            UserDefaults.standard.set(true, forKey: "\(id)")
        }
        notifyController(.favorited(!isFavorite))
        movieDelegate?.movieFavorited()
    }
    
    private func notifyController(_ output: DetailInteractorOutput) {
        delegate?.handleOutput(output)
    }
}
