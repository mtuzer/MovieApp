//
//  MockMainController.swift
//  MovieAppTests
//
//  Created by Mert Tuzer on 5.06.2021.
//

import Foundation
@testable import MovieApp

class MockMainController: MainInteractorDelegate {
    var outputs = [MainInteractorOutput]()
    var movieId = 0
    
    func handleOutput(_ output: MainInteractorOutput) {
        outputs.append(output)
    }
    
    func navigateToMovieDetail(withId id: Int) {
        movieId = id
    }
    
    func movieTapped(withIndex index: Int, interactor: MainInteractor) {
        interactor.movieSelected(atIndex: index)
    }
}
