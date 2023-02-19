//
//  DogsResponseModel.swift
//  DoggieOn
//
//  Created by Victor Lee on 2023/02/09.
//

import Foundation

struct Dog: Codable {
    let breeds: [Breed]?
    let id: String?
    let url: String?
}

struct Breed: Codable {
    let id: Int?
    let name: String?
}

struct MyDog: Codable {
    let id: String?
    let url: String?
    let subId: String?

    enum CodingKeys: String, CodingKey {
        case id, url
        case subId = "sub_id"
    }
}
