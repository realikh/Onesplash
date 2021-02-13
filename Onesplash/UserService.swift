//
//  CollectionService.swift
//  Onesplash
//
//  Created by Мирас on 2/12/21.
//

import Foundation

enum UserServiceError: Error {
    case badResponse(response: URLResponse?)
    case badData
    case badLocalUrl
}


class UserService {
    
    var isPaginating = false
    
    private let accessKey = "g_bih1OD8GhQVHrcjPPqyo7Ho19HZddWwakzUgjVNuM"
    
    static var shared = UserService()
    
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
    
    func searchUsers(with query: String, completion: @escaping ([User]?, Error?) -> Void) {
        var comp = components()
        
        comp.path = "/search/users"
        comp.queryItems = [URLQueryItem(name: "query", value: query)]

        let req = request(url: comp.url!)
        
        let task = session.dataTask(with: req) { data, response, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                completion(nil, UserServiceError.badResponse(response: response!))
                return
            }
            
            guard let data = data else {
                completion(nil, UserServiceError.badData)
                return
            }
            
            do {
                let response = try JSONDecoder().decode(APIResponse.self, from: data)
//                completion(response.results, nil)
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
                completion(nil, UserServiceError.badResponse(response: response))
                return
            }
            
            guard let localUrl = localUrl else {
                completion(nil, UserServiceError.badLocalUrl)
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
    
    func image(user: User, completion: @escaping (Data?, Error?) -> (Void)) {
        let url = URL(string: user.profile_image.medium)!
        download(imageURL: url, completion: completion)
    }
}

