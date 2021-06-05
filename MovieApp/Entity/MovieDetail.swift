//
//  MovieDetail.swift
//  MovieApp
//
//  Created by Mert Tuzer on 3.06.2021.
//

import Foundation

struct MovieDetail: Decodable {
    let id: Int
    let imagePath: String
    let title: String
    let description: String
    let voteCount: Int
    let date: String?
    
    var imageURL: String {
        "https://image.tmdb.org/t/p/w200/" + imagePath
    }
    
    enum CodingKeys: String, CodingKey {
        case id, title
        case description = "overview"
        case imagePath = "poster_path"
        case voteCount = "vote_count"
        case date = "release_date"
    }
}
