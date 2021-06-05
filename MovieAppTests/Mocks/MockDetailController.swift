//
//  MockDetailController.swift
//  MovieAppTests
//
//  Created by Mert Tuzer on 5.06.2021.
//

import Foundation
@testable import MovieApp

class MockDetailController: DetailInteractorDelegate {
    var outputs = [DetailInteractorOutput]()
    
    func handleOutput(_ output: DetailInteractorOutput) {
        outputs.append(output)
    }
    
    func changeFavorite(interactor: DetailInteractor) {
        interactor.setFavorite()
    }
}
