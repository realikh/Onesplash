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
    private(set) var recentSearches = [SearchHistory]()
    private var pageNumber = 0
    private var query = "cats"
    var requestCancelled = false
    
    func fetchData<T: Decodable>(with query: String, type: T.Type) {
        guard !isPaginating else { print("Fetching data already"); return }
        isPaginating = true
        pageNumber += 1
        NetworkEngine.request(endpoint:
                                UnsplashEndpoint
                                .getSearchResults(searchText: query,
                                                  page: pageNumber,
                                                  dataType: String(describing: T.self
                                                  )))
        { (response: Result<APIResponse<T>, Error>) in
            switch response {
            case .success(let response):
                guard !self.requestCancelled else { self.requestCancelled = false; self.isPaginating = false; return }
                self.results.append(contentsOf: response.results)
                guard let insertionIndexPaths = self.getInsertionIndexPaths(for: self.pageNumber) else { print("All data fetched"); return }
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
    
    func addRecentSearch(string: String) {
        if !checkRepition(title: string) {
            let record = CoreDataManager.sharedInstance.createNewSearchRecord(title: string)
            recentSearches.append(record)
            CoreDataManager.sharedInstance.saveContext()
        }
        
    }
    
    func fetchSearchHistory() {
        if let fetchedResult = CoreDataManager.sharedInstance.fetchSearchRecords() {
            recentSearches = fetchedResult
        }
    }
    
    func deleteSearchRecords() {
        for i in recentSearches {
            CoreDataManager.sharedInstance.delete(i)
        }
        recentSearches.removeAll()
    }
    
    private func checkRepition(title: String) -> Bool{
        for i in recentSearches {
            if let safeTitle = i.title{
                if (safeTitle.elementsEqual(title)) {
                    return true
                }
            }
        }
        return false
    }
}
