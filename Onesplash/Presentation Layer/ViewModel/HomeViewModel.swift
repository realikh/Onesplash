//
//  HomeViewMode.swift
//  Onesplash
//
//  Created by Alikhan Khassen on 12.02.2021.
//

import UIKit

protocol ViewModel {
    var results: [Decodable] { get }
    var networkEngine: NetworkEngine { get }
}

extension ViewModel {
    
    func image(url: String, completion: @escaping (UIImage?, Error?) -> Void) {
        networkEngine.download(urlString: url) { data, error in
            guard error == nil else { print(error?.localizedDescription ?? "Unknown"); return }
            guard let data = data else { return }
            let image = UIImage(data: data)
            completion(image, nil)
        }
    }
    
    func getInsertionIndexPaths(for pageNumber: Int) -> [IndexPath]? {
        var indexPaths = [IndexPath]()
        let lowerBound = (pageNumber - 1) * 10
        let upperBound = results.count - 1
        guard lowerBound < results.count else { return nil }
        for index in lowerBound...upperBound {
            indexPaths.append(IndexPath(item: index, section: 0))
        }
        return indexPaths
    }
}

final class HomeViewModel: ViewModel {
    var networkEngine: NetworkEngine = NetworkEngineImpl()
    var didEndRequest: ([IndexPath]?) -> Void = { indexPaths in }
    var results: [Decodable] = [Post]()
    private var pageNumber = 0
    private var isPaginating = false
    
    func fetchPosts() {
        // If data is fetching already
        guard !isPaginating else { return } //
        isPaginating = true
        pageNumber += 1
        networkEngine.request(endpoint: UnsplashEndpoint.getPostResults(page: pageNumber)) { (result: Result<[Post], Error>) in
            switch result {
            case .success(let posts):
                self.results.append(contentsOf: posts)
                guard let insertionIndexPaths = self.getInsertionIndexPaths(for: self.pageNumber) else { return }
                self.didEndRequest(insertionIndexPaths)
                self.isPaginating = false
            default:
                self.isPaginating = false
                break
            }
        }
    }
}
