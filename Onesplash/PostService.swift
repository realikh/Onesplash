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
    
    func posts(completion: @escaping ([Post]?, Error?) -> Void) {
        var comp = components()
        
        comp.path = "/photos"
        let req = request(url: comp.url!)
        
        let task = session.dataTask(with: req) { data, response, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                completion(nil, PostServiceError.badResponse(response: response!))
                return
            }
            
            guard let data = data else {
                completion(nil, PostServiceError.badData)
                return
            }
            
            do {
                let response = try JSONDecoder().decode([Post].self, from: data)
                completion(response, nil)
            } catch let error {
                completion(nil, error)
            }
        }
        
        task.resume()
    }
    
    func searchPosts(with query: String, completion: @escaping ([Post]?, Error?) -> Void) {
        var comp = components()
        
        comp.path = "/search/photos"
        comp.queryItems = [URLQueryItem(name: "query", value: query)]

        let req = request(url: comp.url!)
        
        let task = session.dataTask(with: req) { data, response, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                completion(nil, PostServiceError.badResponse(response: response!))
                return
            }
            
            guard let data = data else {
                completion(nil, PostServiceError.badData)
                return
            }
            
            do {
                let response = try JSONDecoder().decode(APIResponse.self, from: data)
                completion(response.results, nil)
            } catch let error {
                completion(nil, error)
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
                completion(nil, PostServiceError.badResponse(response: response))
                return
            }
            
            guard let localUrl = localUrl else {
                completion(nil, PostServiceError.badLocalUrl)
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
