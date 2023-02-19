//
//  FavouritesResponseModel.swift
//  DoggieOn
//
//  Created by Victor Lee on 2023/02/10.
//

import Foundation


struct Favourite: Codable {
    let id: Int?
    let userID, imageID, subID, createdAt: String?
    let image: Image?

    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case imageID = "image_id"
        case subID = "sub_id"
        case createdAt = "created_at"
        case image
    }
}

struct Image: Codable {
    let id: String?
    let url: String?
}

struct PostFavourite: Codable {
    let message: String?
    let id: Int?
}

struct DeleteFavourite: Codable {
    let message: String?
}
