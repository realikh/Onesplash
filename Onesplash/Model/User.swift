//
//  User.swift
//  Onesplash
//
//  Created by Мирас on 2/12/21.
//

import Foundation

struct UserProfilePhoto: Decodable {
    let medium: String
}

struct User: Decodable {
    let id: String
    let username: String
    let name: String
    let profile_image: UserProfilePhoto
}
