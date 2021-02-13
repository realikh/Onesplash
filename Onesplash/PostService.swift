//
//  PostService.swift
//  Onesplash
//
//  Created by Alikhan Khassen on 27.01.2021.
//

import Foundation

enum PostServiceError: Error {
    case badResponse(response: URLResponse?)
    case badData
    case badLocalUrl
}

fileprivate struct APIResponse: Decodable {
    let results: [Post]
}

class PostService {
    
    private(set) var isPaginating = false
    private let accessKey = "g_bih1OD8GhQVHrcjPPqyo7Ho19HZddWwakzUgjVNuM"
    static var shared = PostService()
    
    let session: URLSession
    
    init() {
        let config: URLSessionConfiguration = .default
        session = URLSession(configuration: config)
    }
    
    private func components() -> URLComponents {
        var comp = URLComponents()
        comp.scheme = "https"
        comp.host = "api.unsplash.com"
        return comp
    }
    
    private func request(url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.addValue("Client-ID \(accessKey)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    func posts(query: String? = nil, pageNumber: Int, completion: @escaping ([Post]?, Error?) -> Void) {
        
        isPaginating = true
        var comp = components()
        comp.queryItems = []
        
        if let query = query { // Search posts
            comp.path = "/search/photos"
            comp.queryItems = [URLQueryItem(name: "query", value: query),
                               URLQueryItem(name: "page", value: "\(pageNumber)")]
        } else { // Posts
            comp.path = "/photos"
            comp.queryItems = [URLQueryItem(name: "page", value: "\(pageNumber)")]
        }
    
        let req = request(url: comp.url!)
        
        let task = session.dataTask(with: req) { data, response, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let data = data else { return }
            
            do {
                if let _ = query {
                    let response = try JSONDecoder().decode(APIResponse.self, from: data)
                    completion(response.results, nil)
                } else {
                    let response = try JSONDecoder().decode([Post].self, from: data)
                    completion(response, nil)
                }
                self.isPaginating = false
            } catch let error {
                completion(nil, error)
            }
        }
        task.resume()
    }
    
    func download(post: Post, completion: @escaping (Data?, Error?) -> Void) {
        guard let imageURL = URL(string: post.urls.regular) else { return }
        let task = session.downloadTask(with: imageURL) { localUrl, response, error in
            if let error = error {
                completion(nil, error)
                return
            }
            guard let localUrl = localUrl else { return }
            do {
                let data = try Data(contentsOf: localUrl)
                completion(data, nil)
            } catch let error {
                completion(nil, error)
            }
        }
        task.resume()
    }
}
