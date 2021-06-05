//
//  Movie.swift
//  MovieApp
//
//  Created by Mert Tuzer on 3.06.2021.
//

import Foundation

struct Movie: Decodable {
    let id: Int
    let title: String
    let description: String
    let imagePath: String
    let date: String?
    let genres: [Int]
    
    var imageURL: String {
        "https://image.tmdb.org/t/p/w200/" + imagePath
    }
    
    enum CodingKeys: String, CodingKey {
        case id, title
        case description = "overview"
        case imagePath = "poster_path"
        case date = "release_date"
        case genres = "genre_ids"
    }
}
