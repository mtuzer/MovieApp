//
//  NetworkClient.swift
//  MovieApp
//
//  Created by Mert Tuzer on 3.06.2021.
//

import Foundation

// MARK: Design of Network Client
enum MovieNetworkError: Error {
    case invalidURL, invalidPayload, noApiKey, unknownError(Error)
}

protocol MovieNetworking {
    func fetchPopularMovies(page: Int, completionHandler: @escaping (Result<PopularMovieResponse, MovieNetworkError>) -> Void)
    func getMovieDetail(withId id: Int, completionHandler: @escaping (Result<MovieDetail, MovieNetworkError>) -> Void)
}

enum MovieURL {
    case movies(page: Int), movieDetail(id: Int)
    
    var url: URL? {
        var components = URLComponents(string: "https://api.themoviedb.org")! // we must be sure that it is working !
        switch self {
        case .movies(let page):
            components.path = "/3/movie/popular"
            components.queryItems = .init(["language": MovieAPI.language, "api_key": MovieAPI.apiKey, "page": "\(page)"])
            return components.url
        case .movieDetail(let id):
            components.path = "/3/movie/\(id)"
            components.queryItems = .init(["language": MovieAPI.language, "api_key": MovieAPI.apiKey])
            return components.url
        }
    }
}

class MovieNetworkClient: MovieNetworking {
    func fetchPopularMovies(page: Int, completionHandler: @escaping (Result<PopularMovieResponse, MovieNetworkError>) -> Void) {
        guard MovieAPI.apiKey != "" else {
            completionHandler(.failure(.noApiKey))
            return
        }
        
        guard let url = MovieURL.movies(page: page).url else {
            completionHandler(.failure(.invalidURL))
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, _, error) in
            if let error = error {
                completionHandler(.failure(.unknownError(error)))
                return
            }
                        
            let decoder = JSONDecoder()
            guard let data = data,
                  let decodedData = try? decoder.decode(PopularMovieResponse.self, from: data) else {
                completionHandler(.failure(.invalidPayload))
                return
            }
            completionHandler(.success(decodedData))
        }.resume()
    }
    
    func getMovieDetail(withId id: Int, completionHandler: @escaping (Result<MovieDetail, MovieNetworkError>) -> Void) {
        guard MovieAPI.apiKey != "" else {
            completionHandler(.failure(.noApiKey))
            return
        }
        
        guard let url = MovieURL.movieDetail(id: id).url else {
            completionHandler(.failure(.invalidURL))
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, _, error) in
            if let error = error {
                completionHandler(.failure(.unknownError(error)))
                return
            }
            
            let decoder = JSONDecoder()
            guard let data = data,
                  let decodedData = try? decoder.decode(MovieDetail.self, from: data) else {
                completionHandler(.failure(.invalidPayload))
                return
            }
            completionHandler(.success(decodedData))
        }.resume()
    }
}
