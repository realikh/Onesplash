//
//  NetworkEngine.swift
//  Onesplash
//
//  Created by Alikhan Khassen on 13.02.2021.
//

import Foundation

final class NetworkEngine {
    
    class func request<T: Decodable>(endpoint: Endpoint, completion: @escaping (Result<T, Error>) -> Void) {
        
        let accessKey = "g_bih1OD8GhQVHrcjPPqyo7Ho19HZddWwakzUgjVNuM"
        var components = URLComponents()
        components.scheme = endpoint.scheme
        components.host = endpoint.baseURL
        components.path = endpoint.path
        components.queryItems = endpoint.parameters
        
        guard let url = components.url else { return }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.addValue("Client-ID \(accessKey)", forHTTPHeaderField: "Authorization")
        
        let session = URLSession(configuration: .default)
        let dataTask = session.dataTask(with: urlRequest) { data, response, error in
            
            guard error == nil else {
                completion(.failure(error!))
                print(error?.localizedDescription ?? "Unknown")
                return
            }
            
            guard let data = data else { return }
        
            if let responseObject = try? JSONDecoder().decode(T.self, from: data) {
                completion(.success(responseObject))
            } else {
                let error = NSError(domain: "", code: 200, userInfo: [NSLocalizedDescriptionKey: "Response error"])
                completion(.failure(error))
                print(error.localizedDescription)
            }
        }
        dataTask.resume()
    }
    
    class func download(urlString: String, completion: @escaping(Data?, Error?) -> Void) {
        
        guard let url = URL(string: urlString) else { print("Invalid URL"); return }
        let session = URLSession(configuration: .default)
        
        let task = session.downloadTask(with: url) { localUrl, response, error in
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
