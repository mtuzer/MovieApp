//
//  MainInteractor.swift
//  MovieApp
//
//  Created by Mert Tuzer on 3.06.2021.
//

import Foundation

// MARK: Design Necessary Protocols for Interactor
protocol MainInteractable: AnyObject {
    var delegate: MainInteractorDelegate? { get set }
    func load()                                  // initial load to fill screen content
    func loadMoreTapped()                        // respond to the load more button
    func movieSelected(withId id: Int)           // respond to movie selection
    func searchMovie(withTitle title: String)    // respond to search query
}

enum MainInteractorOutput {
    case showMovies([MovieViewModel])   // depending on network request result, give view model
    case setLoading(Bool)              // set loading, with respect to fetching situation
    case setTitle(String)              // set controller title
    case refreshFavorites(([MovieViewModel], Int))
    case throwErrorMessage(String)     // depending on network request result, throw errors
}

// MARK: Protocol for Responder to Interactor
protocol MainInteractorDelegate: AnyObject {
    func handleOutput(_ output: MainInteractorOutput)   // respond depending on outputs
    func navigateToMovieDetail(withId id: Int)        // prepare to navigate with movie id
}

// MARK: Main Interactor
class MainInteractor: MainInteractable {
    weak var delegate: MainInteractorDelegate?
    private let service: MovieNetworking
    private var currentPage: Int = 1
    private var selectedIndex: Int?
    
    init(service: MovieNetworking) {
        self.service = service
    }
    
    private var movieList = [Movie]()
    private var filteredMovieList = [Movie]()
    
    func load() {
        notifyController(.setTitle("Movies"))
        notifyController(.setLoading(true))
        
        fetchMovies()
    }
    
    func loadMoreTapped() {
        notifyController(.setLoading(true))
        fetchMovies()
    }
    
    func movieSelected(withId id: Int) {
        selectedIndex = id
        delegate?.navigateToMovieDetail(withId: id)
    }
    
    func searchMovie(withTitle title: String) {
        filterMovies(title: title)
    }
    
    private func fetchMovies() {
        service.fetchPopularMovies(page: currentPage) { [weak self] result in
            switch result {
            case .success(let movies):
                self?.movieList.append(contentsOf: movies.results)
                self?.filteredMovieList = self?.movieList ?? []
                let movieViewModels = self?.movieList.map { MovieViewModel.from(movie: $0) } ?? []
                self?.notifyController(.showMovies(movieViewModels))
                self?.currentPage += 1 // increase page number to be used when tapping load more
            case .failure(let error):
                self?.handleError(error: error)
                
            }
            self?.notifyController(.setLoading(false))
        }
    }
    
    private func filterMovies(title: String) {
        filteredMovieList = movieList.filter({ $0.title.hasPrefix(title) })
        notifyController(.showMovies(filteredMovieList.map { MovieViewModel.from(movie: $0) }))
    }
    
    private func handleError(error: MovieNetworkError) {
        var message = "An unknown error occurred."
        switch error {
        case .invalidURL:
            message = "An invalid URL is used to fetch movies."
        case .invalidPayload, .unknownError:
            break
        case .noApiKey:
            message = "Please get an API key to fetch movies."
        }
        
        notifyController(.throwErrorMessage(message))
    }
        
    private func notifyController(_ output: MainInteractorOutput) {
        delegate?.handleOutput(output)
    }
}

// MARK: Response to Change in Favorite Selection in Detail Screen
extension MainInteractor: MovieFavoriteDelegate {
    func movieFavorited() { // update cell due to the change
        if let index = filteredMovieList.firstIndex(where: { $0.id == selectedIndex }) {
            let movieViewModel = filteredMovieList.map { MovieViewModel.from(movie: $0) } // update favorite in ViewModel
            notifyController(.refreshFavorites((movieViewModel, index)))
        }
    }
}
