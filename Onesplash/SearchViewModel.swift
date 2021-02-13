//
//  SearchViewModel.swift
//  Onesplash
//
//  Created by Alikhan Khassen on 13.02.2021.
//

import UIKit

final class SearchViewModel {
//    var didEndPostRequest: ([IndexPath]) -> Void = { indexPaths in }
    var didEndRequest: () -> Void = {}
    private let postService = PostService.shared
    private let collectionService = CollectionService.shared
    private let userService = UserService.shared
    private(set) var results = [Decodable]()
    private(set) var isPaginating = false
    private var pageNumber = 0
    private var query = "cats"
    
    func fetchData<T: Decodable>(with query: String, type: T.Type) {
        guard !isPaginating else { print("Fetching data already"); return }
        isPaginating = true
        pageNumber += 1
        NetworkEngine.request(endpoint:
                                UnsplashEndpoint.getSearchResults(searchText: query,
                                                                  page: 1,
                                                                  dataType: String(describing: T.self
                                                                          )))
        { (response: Result<APIResponse<T>, Error>) in
            switch response {
            case .success(let response):
                self.results.append(contentsOf: response.results)
                self.didEndRequest()
                self.isPaginating = false
            default:
                self.isPaginating = false
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
    
    func newQuery() {
        pageNumber = 0
        results = []
        didEndRequest()
    }
}
