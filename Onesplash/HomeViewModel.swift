//
//  HomeViewMode.swift
//  Onesplash
//
//  Created by Alikhan Khassen on 12.02.2021.
//

import Foundation

final class HomeViewModel {
    var didEndRequest: ([IndexPath]) -> Void = { indexPaths in }
    private let postService = PostService.shared
    private(set) var posts = [Post]()
    private var pageNumber = 0
    
    func fetchPosts() {
        guard !postService.isPaginating else { print("Fetching Data"); return }
        pageNumber += 1
        postService.posts(pageNumber: pageNumber) { [weak self] posts, error in
            guard let posts = posts, self != nil else { return }
            self!.posts.append(contentsOf: posts)
            self!.didEndRequest((self?.getIndexPaths(for: self!.pageNumber))!)
        }
    }
    
    private func getIndexPaths(for pageNumber: Int) -> [IndexPath] {
        var indexPaths = [IndexPath]()
        for index in (pageNumber - 1)*10...(pageNumber * 10 - 1) {
            indexPaths.append(IndexPath(item: index, section: 0))
        }
        return indexPaths
    }
}
