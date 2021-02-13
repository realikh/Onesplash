//
//  CollectionService.swift
//  Onesplash
//
//  Created by Мирас on 2/12/21.
//

import Foundation

enum CollectionServiceError: Error {
    case badResponse(response: URLResponse?)
    case badData
    case badLocalUrl
}


class CollectionService {
    
    var isPaginating = false
    
    private let accessKey = "g_bih1OD8GhQVHrcjPPqyo7Ho19HZddWwakzUgjVNuM"
    
    static var shared = CollectionService()
    
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
    
    func searchCollections(with query: String, completion: @escaping ([Collection]?, Error?) -> Void) {
        var comp = components()
        
        comp.path = "/search/collections"
        comp.queryItems = [URLQueryItem(name: "query", value: query)]

        let req = request(url: comp.url!)
        
        let task = session.dataTask(with: req) { data, response, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                completion(nil, CollectionServiceError.badResponse(response: response!))
                return
            }
            
            guard let data = data else {
                completion(nil, CollectionServiceError.badData)
                return
            }
            
            do {
//                let response = try JSONDecoder().decode(APIResponse.self, from: data)
//                completion(response.results, nil)
            } catch let error {
//                completion(nil, error)
            }
        }
        
        task.resume()
    }
    
    private func download(imageURL: URL, completion: @escaping (Data?, Error?) -> (Void)) {
        let task = session.downloadTask(with: imageURL) { localUrl, response, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                completion(nil, CollectionServiceError.badResponse(response: response))
                return
            }
            
            guard let localUrl = localUrl else {
                completion(nil, CollectionServiceError.badLocalUrl)
                return
            }
            
            do {
                let data = try Data(contentsOf: localUrl)
                completion(data, nil)
            } catch let error {
                completion(nil, error)
            }
        }
        
        task.resume()
    }
    
    func image(post: Post, completion: @escaping (Data?, Error?) -> (Void)) {
        let url = URL(string: post.urls.regular)!
        download(imageURL: url, completion: completion)
    }
}

