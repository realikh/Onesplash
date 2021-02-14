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
}

enum UnsplashEndpoint: Endpoint {
    
    case getPostResults(page: Int)
    case getSearchResults(searchText: String, page: Int, dataType: String)
    case getCollectionPhotos(id: Int, page: Int)
    
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
        case .getPostResults:
            return "/photos"
        case .getSearchResults( _, _, let dataType):
            switch dataType {
            case String(describing: Post.self):
                return "/search/photos"
            case String(describing: Collection.self):
                return "/search/collections"
            case String(describing: User.self):
                return "/search/users"
            default:
                return "/photos"
            }
        case .getCollectionPhotos(id: let id, page: _):
            return "/collections/\(id)/photos"
        }
    }
    
    var parameters: [URLQueryItem] {
        switch self {
        case .getPostResults(let page):
            return [URLQueryItem(name: "page", value: "\(page)")]
        case .getSearchResults(let searchText, let page, _):
            return [URLQueryItem(name: "page", value: "\(page)"),
                    URLQueryItem(name: "query", value: searchText)]
        case .getCollectionPhotos(id: _, page: let page):
            return [URLQueryItem(name: "page", value: "\(page)")]
        }
    }
}
