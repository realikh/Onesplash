//
//  HomeViewMode.swift
//  Onesplash
//
//  Created by Alikhan Khassen on 12.02.2021.
//

import UIKit

final class HomeViewModel {
    
    var didEndRequest: ([IndexPath]) -> Void = { indexPaths in }
    private let postService = PostService.shared
    private(set) var posts = [Post]()
    private var pageNumber = 0
    
    func fetchPosts(query: String? = nil) {
        guard !postService.isPaginating else { print("Fetching Data"); return }
        pageNumber += 1
        postService.posts(pageNumber: pageNumber) { [weak self] posts, error in
            guard let posts = posts, self != nil else { return }
            self!.posts.append(contentsOf: posts)
            self!.didEndRequest((self?.getInsertionIndexPaths(for: self!.pageNumber))!)
        }
    }
    
    func image(post: Post, completion: @escaping (UIImage?, Error?) -> Void) {
        postService.download(post: post) { data, error in
            guard let data = data else { return }
            let image = UIImage(data: data)
            completion(image, nil)
        }
    }
    
    private func getInsertionIndexPaths(for pageNumber: Int) -> [IndexPath] {
        var indexPaths = [IndexPath]()
        for index in (pageNumber - 1) * 10...(pageNumber * 10 - 1) {
            indexPaths.append(IndexPath(item: index, section: 0))
        }
        return indexPaths
    }
}
