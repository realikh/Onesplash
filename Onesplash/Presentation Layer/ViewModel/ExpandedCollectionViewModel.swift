//
//  HomeViewMode.swift
//  Onesplash
//
//  Created by Alikhan Khassen on 12.02.2021.
//

import UIKit


final class ExpandedCollectionViewModel: ViewModel {
    
    var networkEngine: NetworkEngine = NetworkEngineImpl()
    
    var didEndRequest: ([IndexPath]?) -> Void = { indexPaths in }
    var results: [Decodable] = [Post]()
    private var pageNumber = 0
    private var isPaginating = false
    
    func fetchPosts(with id: Int) {
        // If data is fetching already
        guard !isPaginating else { print("Already fetching data"); return } //
        isPaginating = true
        pageNumber += 1
        networkEngine.request(endpoint: UnsplashEndpoint.getCollectionPhotos(id: id, page: pageNumber)) { (result: Result<[Post], Error>) in
            switch result {
            case .success(let posts):
                self.results.append(contentsOf: posts)
                guard let insertionIndexPaths = self.getInsertionIndexPaths(for: self.pageNumber) else { print("All data fetched"); return }
                self.didEndRequest(insertionIndexPaths)
                self.isPaginating = false
            default:
                self.isPaginating = false
                break
            }
        }
    }
}
