//
//  Array+Extension.swift
//  MovieApp
//
//  Created by Mert Tuzer on 4.06.2021.
//

import Foundation

public extension Array {
    struct IndexOutOfBoundsError: Error { }
    
    func element(at index: Int) throws -> Element {
        guard index >= 0 && index < count else {
            throw IndexOutOfBoundsError()
        }
        return self[index]
    }
}

extension Array where Element == URLQueryItem {
    init<T: LosslessStringConvertible>(_ dictionary: [String: T]) {
        self = dictionary.map({ (key, value) -> Element in
            URLQueryItem(name: key, value: String(value))
        })
    }
}
