//
//  MockNetworkService.swift
//  MovieAppTests
//
//  Created by Mert Tuzer on 5.06.2021.
//

import Foundation
@testable import MovieApp

class MockNetworkService: MovieNetworking {
    var mockPopularMovieResponse: (Result<PopularMovieResponse, MovieNetworkError>)?
    var mockMovieDetailResponse: (Result<MovieDetail, MovieNetworkError>)?
    
    func fetchPopularMovies(page: Int, completionHandler: @escaping (Result<PopularMovieResponse, MovieNetworkError>) -> Void) {
        if let mockResp = mockPopularMovieResponse {
            completionHandler(mockResp)
        }
    }
    
    func getMovieDetail(withId id: Int, completionHandler: @escaping (Result<MovieDetail, MovieNetworkError>) -> Void) {
        if let mockResp = mockMovieDetailResponse {
            completionHandler(mockResp)
        }
    }
}
