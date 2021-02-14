//
//  SearchViewModel.swift
//  Onesplash
//
//  Created by Alikhan Khassen on 13.02.2021.
//

import UIKit

final class SearchViewModel: ViewModel {
    var didEndRequest: ([IndexPath]) -> Void = {_ in}
    private(set) var results = [Decodable]()
    private(set) var isPaginating = false
    private var pageNumber = 0
    private var query = "cats"
    
    func fetchData<T: Decodable>(with query: String, type: T.Type) {
        guard !isPaginating else { print("Fetching data already"); return }
        isPaginating = true
        pageNumber += 1
        guard let insertionIndexPaths = getInsertionIndexPaths(for: pageNumber) else { print("All data fetched"); return }
        NetworkEngine.request(endpoint:
                                UnsplashEndpoint
                                .getSearchResults(searchText: query,
                                                                  page: pageNumber,
                                                                  dataType: String(describing: T.self
                                                                          )))
        { (response: Result<APIResponse<T>, Error>) in
            switch response {
            case .success(let response):
                self.results.append(contentsOf: response.results)
                guard self.results.count > 0 else { self.isPaginating = false; return }
                self.didEndRequest(insertionIndexPaths)
                self.isPaginating = false
            case .failure:
                self.isPaginating = false
            }
        }
    }
    
    func fetchData(searchText: String, scopeButtonIndex: Int) {
        switch scopeButtonIndex {
        case 0:
            fetchData(with: searchText, type: Post.self)
        case 1:
            fetchData(with: searchText, type: Collection.self)
        case 2:
            fetchData(with: searchText, type: User.self)
        default:
            break
        }
    }
    
    func newQuery() {
        isPaginating = false
        pageNumber = 0
        results = []
    }
}
