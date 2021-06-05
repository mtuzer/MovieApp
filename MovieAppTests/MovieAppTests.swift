//
//  MovieAppTests.swift
//  MovieAppTests
//
//  Created by Mert Tuzer on 3.06.2021.
//

import XCTest
@testable import MovieApp

class MovieAppTests: XCTestCase {
    
    fileprivate var mockMainController: MockMainController!
    fileprivate var mockDetailController: MockDetailController!
    fileprivate var mockMainInteractor: MainInteractor!
    fileprivate var mockDetailInteractor: DetailInteractor!
    fileprivate var mockNetworkService: MockNetworkService!
    
    private let movieDetailId = 897

    // MARK: Initialize Mocks
    override func setUpWithError() throws {
        mockMainController = MockMainController()
        mockDetailController = MockDetailController()
        mockNetworkService = MockNetworkService()
        mockMainInteractor = MainInteractor(service: mockNetworkService)
        mockDetailInteractor = DetailInteractor(movieId: movieDetailId, service: mockNetworkService)
        mockMainInteractor.delegate = mockMainController
        mockDetailInteractor.delegate = mockDetailController
    }

    // MARK: Main Tests
    func testMainInteractor() throws {
        // MARK: Initial Loading with Success
        // given:
        let popularMovieResponse = mockMovieResponse(page: 0)
        mockNetworkService.mockPopularMovieResponse = .success(popularMovieResponse)
        
        // when:
        mockMainInteractor.load()
        
        // then:
        let firstOutput = try mockMainController.outputs.element(at: 0)
        switch firstOutput {
        case .setTitle:
            break // success
        default:
            XCTFail("First output must be the title.")
        }
        
        let secondOutput = try mockMainController.outputs.element(at: 1)
        switch secondOutput {
        case .setLoading(let isLoading):
            XCTAssertEqual(isLoading, true)
        default:
            XCTFail("Second output must be the loading.")
        }
        
        let thirdOutput = try mockMainController.outputs.element(at: 2)
        switch thirdOutput {
        case .showMovies(let viewModel):
            XCTAssertEqual(viewModel.first?.name, "Movie1")
        default:
            XCTFail("Third output must show movies.")
        }
        
        let fourthOutput = try mockMainController.outputs.element(at: 3)
        switch fourthOutput {
        case .setLoading(let isLoading):
            XCTAssertEqual(isLoading, false)
        default:
            XCTFail("Fourth output must be the loading.")
        }
        
        // MARK: Load More Tapped
        // given2:
        let popularMovieResponse2 = mockMovieResponse(page: 1)
        mockNetworkService.mockPopularMovieResponse = .success(popularMovieResponse2)
        
        // when2:
        mockMainInteractor.loadMoreTapped()
        
        // then2:
        let fifthOutput = try mockMainController.outputs.element(at: 4)
        switch fifthOutput {
        case .setLoading(let isLoading):
            XCTAssertEqual(isLoading, true)
        default:
            XCTFail("The output must be the loading.")
        }
        
        let sixthOutput = try mockMainController.outputs.element(at: 5)
        switch sixthOutput {
        case .showMovies(let viewModel):
            XCTAssertEqual(viewModel.count, 4)
        default:
            XCTFail("The output must be show new movies.")
        }
    }
    
    func testMainInteractorNetworkFailure() throws {
        // MARK: Initial Loading with Failure
        // given:
        mockNetworkService.mockPopularMovieResponse = .failure(.invalidURL)
        
        // when:
        mockMainInteractor.load()
        
        // then:
        let firstOutput = try mockMainController.outputs.element(at: 0)
        switch firstOutput {
        case .setTitle:
            break // success
        default:
            XCTFail("First output must be the title.")
        }
        
        let secondOutput = try mockMainController.outputs.element(at: 1)
        switch secondOutput {
        case .setLoading(let isLoading):
            XCTAssertEqual(isLoading, true)
        default:
            XCTFail("Second output must be the loading.")
        }
        
        let thirdOutput = try mockMainController.outputs.element(at: 2)
        switch thirdOutput {
        case .throwErrorMessage(let message):
            XCTAssertEqual(message, "An invalid URL is used to fetch movies.")
        default:
            XCTFail("The output must be an error.")
        }
        
        let fourthOutput = try mockMainController.outputs.element(at: 3)
        switch fourthOutput {
        case .setLoading(let isLoading):
            XCTAssertEqual(isLoading, false)
        default:
            XCTFail("Fourth output must be the loading.")
        }
    }
    
    func testNavigationFromMainToDetailFlow() throws {
        // MARK: Tapping Movie From Main Controller
        // given:
        let id = 179
        
        // when:
        mockMainController.movieTapped(withId: id, interactor: mockMainInteractor)
        
        // then:
        XCTAssertEqual(mockMainController.movieId, id)
    }
    
    // MARK: Detail Tests
    func testDetailInteractor() throws {
        // MARK: Initial Loading with Success
        // given:
        let movieDetailResponse = mockMovieDetail(id: movieDetailId)
        mockNetworkService.mockMovieDetailResponse = .success(movieDetailResponse)
        
        // when:
        mockDetailInteractor.load()
        
        // then:
        let firstOutput = try mockDetailController.outputs.element(at: 0)
        switch firstOutput {
        case .setTitle:
            break // success
        default:
            XCTFail("First output must be the title.")
        }
        
        let secondOutput = try mockDetailController.outputs.element(at: 1)
        switch secondOutput {
        case .setLoading(let isLoading):
            XCTAssertEqual(isLoading, true)
        default:
            XCTFail("Second output must be the loading.")
        }
        
        let thirdOutput = try mockDetailController.outputs.element(at: 2)
        switch thirdOutput {
        case .favorited(let isFavorite):
            XCTAssertEqual(isFavorite, UserDefaults.standard.bool(forKey: "\(movieDetailId)"))
        default:
            XCTFail("Third output must be related to favorite.")
        }
        
        let fourthOutput = try mockDetailController.outputs.element(at: 3)
        switch fourthOutput {
        case .showMovieDetail(let viewModel):
            XCTAssertEqual(viewModel.vote, "\(123) ⭐")
        default:
            XCTFail("Fourth output must show detail.")
        }
        
        let fifthOutput = try mockDetailController.outputs.element(at: 4)
        switch fifthOutput {
        case .setLoading(let isLoading):
            XCTAssertEqual(isLoading, false)
        default:
            XCTFail("Fifth output must be the loading.")
        }
    }
    
    func testDetailInteractorNetworkFailure() throws {
        // MARK: Initial Loading with Failure
        // given:
        mockNetworkService.mockMovieDetailResponse = .failure(.invalidPayload)
        
        // when:
        mockDetailInteractor.load()
        
        // then:
        let firstOutput = try mockDetailController.outputs.element(at: 0)
        switch firstOutput {
        case .setTitle:
            break // success
        default:
            XCTFail("First output must be the title.")
        }
        
        let secondOutput = try mockDetailController.outputs.element(at: 1)
        switch secondOutput {
        case .setLoading(let isLoading):
            XCTAssertEqual(isLoading, true)
        default:
            XCTFail("Second output must be the loading.")
        }
        
        let thirdOutput = try mockDetailController.outputs.element(at: 2)
        switch thirdOutput {
        case .favorited(let isFavorite):
            XCTAssertEqual(isFavorite, UserDefaults.standard.bool(forKey: "\(movieDetailId)"))
        default:
            XCTFail("Third output must be related to favorite.")
        }
        
        let fourthOutput = try mockDetailController.outputs.element(at: 3)
        switch fourthOutput {
        case .throwErrorMessage(let message):
            XCTAssertEqual(message, "An unknown error occurred.")
        default:
            XCTFail("The output must be an error.")
        }
        
        let fifthOutput = try mockDetailController.outputs.element(at: 4)
        switch fifthOutput {
        case .setLoading(let isLoading):
            XCTAssertEqual(isLoading, false)
        default:
            XCTFail("Fourth output must be the loading.")
        }
    }
    
    func testDetailInteractorFavoriteFlow() throws {
        // MARK: Tapping Favorite from Detail Controller
        // given:
        let id = movieDetailId
        
        // when:
        mockDetailController.changeFavorite(interactor: mockDetailInteractor)
        
        // then:
        let firstOutput = try mockDetailController.outputs.element(at: 0)
        switch firstOutput {
        case .favorited(let isFavorite):
            XCTAssertEqual(isFavorite, UserDefaults.standard.bool(forKey: "\(id)"))
        default:
            XCTFail("First output must be the title.")
        }
    }
    
    func testMovieParsing() throws {
        let bundle = Bundle(for: MovieAppTests.self)
        let url = bundle.url(forResource: "popularMovies", withExtension: "json")
        let data = try Data(contentsOf: url!) // we can use !, since we created the file, and know that it exists
        let decoder = JSONDecoder()
        let popularMovieResponse = try decoder.decode(PopularMovieResponse.self, from: data)
        let movies = popularMovieResponse.results
        let firstMovie = movies.first

        XCTAssertEqual(movies.count, 20)
        XCTAssertEqual(firstMovie?.title, "Cruella")
        XCTAssertEqual(firstMovie?.imageURL, "https://image.tmdb.org/t/p/w200/" + (firstMovie?.imagePath ?? ""))
    }
    
    // MARK: JSON Parsing
    func testMovieDetailParsing() throws {
        let bundle = Bundle(for: MovieAppTests.self)
        let url = bundle.url(forResource: "movieDetail", withExtension: "json")
        let data = try Data(contentsOf: url!) // we can use !, since we created the file, and know that it exists
        let decoder = JSONDecoder()
        let movieDetail = try decoder.decode(MovieDetail.self, from: data)

        XCTAssertEqual(movieDetail.id, 287947)
        XCTAssertEqual(movieDetail.title, "Shazam!")
        XCTAssertEqual(movieDetail.imageURL, "https://image.tmdb.org/t/p/w200/" + movieDetail.imagePath)
    }

    // MARK: Response Generation
    private func mockMovieResponse(page: Int) -> PopularMovieResponse {
        let mockMovie1 = Movie(id: 123,
                               title: "Movie1",
                               description: "Description1",
                               imagePath: "Path1",
                               date: "01-01-21",
                               genres: [0,1])
        
        let mockMovie2 = Movie(id: 456,
                               title: "Movie2",
                               description: "Description2",
                               imagePath: "Path2",
                               date: "02-02-21",
                               genres: [2,3])
        
        let mockMovies = page % 2 == 0 ? [mockMovie1, mockMovie2] : [mockMovie1, mockMovie2].reversed()
        
        return PopularMovieResponse(page: page,
                                    results: mockMovies)
    }
    
    private func mockMovieDetail(id: Int) -> MovieDetail {
        return MovieDetail(id: id,
                           imagePath: "detailPath",
                           title: "detailTitle",
                           description: "detailDescription",
                           voteCount: 123,
                           date: "03-03-21")
    }
}
