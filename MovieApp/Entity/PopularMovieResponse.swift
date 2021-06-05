//
//  PopularMovieResponse.swift
//  MovieApp
//
//  Created by Mert Tuzer on 3.06.2021.
//

import Foundation

struct PopularMovieResponse: Decodable {
    let page: Int
    let results: [Movie]
}
