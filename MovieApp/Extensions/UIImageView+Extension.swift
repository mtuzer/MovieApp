//
//  UIImageView+Extension.swift
//  MovieApp
//
//  Created by Mert Tuzer on 4.06.2021.
//

import UIKit

let imageCache = NSCache<NSString, UIImage>()

extension UIImageView {
    func loadImageFromURLString(urlString: String) {
        // if it is in cache, return from cache
        if let image = imageCache.object(forKey: urlString as NSString) {
            self.image = image
            return
        }
        
        guard let url = URL(string: urlString) else {
            return
        }
        
        // otherwise, download imageData and cache if exists in received data
        URLSession.shared.dataTask(with: url) { (data, _, error) in
            guard error == nil else { return }
            guard let imageData = data else { return }
            
            DispatchQueue.main.async {
                let imageToBeCached = UIImage(data: imageData)
                if let imageNotNil = imageToBeCached {
                    imageCache.setObject(imageNotNil, forKey: urlString as NSString)
                    self.image = imageNotNil
                } else {
                    self.image = nil
                }
            }
        }.resume()
    }
}
