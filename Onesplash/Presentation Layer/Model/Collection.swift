//
//  Collection.swift
//  Onesplash
//
//  Created by Мирас on 2/12/21.
//

import Foundation

struct CollectionOwner: Decodable {
    let name: String
}

struct Collection: Decodable {
    let id: String
    let title: String
    let cover_photo: Post
    let user: CollectionOwner
}
