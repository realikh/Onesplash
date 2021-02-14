//
//  HomeViewMode.swift
//  Onesplash
//
//  Created by Alikhan Khassen on 12.02.2021.
//

import UIKit

protocol ViewModel {
    var results: [Decodable] { get }
}

extension ViewModel {
    func image(url: String, completion: @escaping (UIImage?, Error?) -> Void) {
        NetworkEngine.download(urlString: url) { data, error in
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
        print("\(lowerBound) \(upperBound)")
        guard lowerBound < results.count else { return nil }
        for index in lowerBound...upperBound {
            print(index)
            indexPaths.append(IndexPath(item: index, section: 0))
        }
        return indexPaths
    }
}

final class HomeViewModel: ViewModel {
    
    var didEndRequest: ([IndexPath]?) -> Void = { indexPaths in }
    var results: [Decodable] = [Post]()
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
