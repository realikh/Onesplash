//
//  SearchViewModel.swift
//  Onesplash
//
//  Created by Alikhan Khassen on 13.02.2021.
//

import UIKit

final class SearchViewModel {
    var didEndPostRequest: ([IndexPath]) -> Void = { indexPaths in }
    var didEndCollectionRequest: () -> Void = {}
    var didEndUserRequest: () -> Void = {}
    private let postService = PostService.shared
    private let collectionService = CollectionService.shared
    private let userService = UserService.shared
    private(set) var posts = [Post]()
    private(set) var collections = [Collection]()
    private(set) var users = [User]()
    private var pageNumber = 0
    private var query = "cats"
    
    func fetchPosts(with query: String) {
        if query.lowercased() != self.query.lowercased() {
            pageNumber = 0
            posts = []
            self.query = query
        }
        guard !postService.isPaginating else { print("Fetching Data"); return }
        pageNumber += 1
        postService.posts(query: query, pageNumber: pageNumber) { [weak self] posts, error in
            guard let posts = posts, self != nil else { return }
            self!.posts.append(contentsOf: posts)
            self!.didEndPostRequest((self?.getInsertionIndexPaths(for: self!.pageNumber))!)
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
