//
//  Endpoint.swift
//  Onesplash
//
//  Created by Alikhan Khassen on 13.02.2021.
//

import Foundation

protocol Endpoint {
    var scheme: String { get }
    var baseURL: String { get }
    var path: String { get }
    var parameters: [URLQueryItem] { get }
//    var method: String { get }
}

enum UnsplashEndpoint: Endpoint {
    
    case getResults(page: Int)
    case getSearchResults(searchText: String, page: Int)
    
    var scheme: String {
        switch self {
        default:
            return "https"
        }
    }
    
    var baseURL: String {
        switch self {
        default:
            return "api.unsplash.com"
        }
    }
    
    var path: String {
        switch self {
        case .getResults:
            return "/photos"
        case .getSearchResults:
            return "/search/photos"
        }
    }
    
    var parameters: [URLQueryItem] {
        switch self {
        case .getResults(let page):
            return [URLQueryItem(name: "page", value: "\(page)")]
        case .getSearchResults(let searchText, let page):
            return [URLQueryItem(name: "page", value: "\(page)"),
                    URLQueryItem(name: "query", value: searchText)]
        }
    }
//    
//    var method: String {
//        switch self {
//        default: return "GET"
//        }
//    }
}
