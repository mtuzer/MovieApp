//
//  Spinner.swift
//  MovieApp
//
//  Created by Mert Tuzer on 4.06.2021.
//

import UIKit

class Spinner {
    private var activityIndicator = UIActivityIndicatorView()

    static var shared = Spinner()
    private init() {}

    func startAnimating() {
        guard let view = UIApplication.shared.windows.filter({ $0.isKeyWindow }).first?.rootViewController?.view else {
            return
        }
        
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        activityIndicator.center = view.center
        activityIndicator.style = .large
        activityIndicator.color = .red
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
    }

    func stopAnimatimating() {
        activityIndicator.stopAnimating()
    }

}
