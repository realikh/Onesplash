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
                print("Error")
            }
        }
        dataTask.resume()
    }
}
