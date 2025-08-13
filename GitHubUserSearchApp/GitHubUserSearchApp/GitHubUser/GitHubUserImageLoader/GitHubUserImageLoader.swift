//
//  GitHubUserImageLoader.swift
//  GitHubUserSearchApp
//
//  Created by Md Mozammil on 13/08/25.
//

import Foundation
import SwiftUI
import Combine

final class ImageLoader: ObservableObject {
    @Published var image: UIImage?
    private var cancellable: AnyCancellable?
    // This is for caching
    private static let cache = NSCache<NSURL, UIImage>()

    func load(url: URL?) {
        guard let url = url else {
            return
        }
        if let cached = Self.cache.object(forKey: url as NSURL) {
            self.image = cached
            return
        }
        cancellable = URLSession.shared.dataTaskPublisher(for: url)
            .map { UIImage(data: $0.data) }
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] img in
                if let img = img {
                    Self.cache.setObject(img, forKey: url as NSURL)
                }
                self?.image = img
            })
    }

    func cancel() {
        cancellable?.cancel()
    }
}
