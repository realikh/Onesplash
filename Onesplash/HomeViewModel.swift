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
    private var isPaginating = false
    
    func fetchPosts() {
        // If data is fetching already
        guard !isPaginating else { print("Already fetching data"); return } //
        isPaginating = true
        pageNumber += 1
        NetworkEngine.request(endpoint: UnsplashEndpoint.getPostResults(page: pageNumber)) { (result: Result<[Post], Error>) in
            switch result {
            case .success(let posts):
                self.posts.append(contentsOf: posts)
                self.didEndRequest(self.getInsertionIndexPaths(for: self.pageNumber))
                self.isPaginating = false
            default:
                self.isPaginating = false
                break
            }
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
