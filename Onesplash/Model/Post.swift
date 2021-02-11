//
//  Image.swift
//  Onesplash
//
//  Created by Alikhan Khassen on 22.01.2021.
//

import Foundation


struct PostUser: Decodable {
    let name: String
}

struct PostUrls: Decodable {
    let regular: String
}

struct Post: Decodable {
    let id: String
    let description: String?
    let width: Double
    let height: Double
    let color: String
    let user: PostUser
    let urls: PostUrls
}
