//
//  DataModel.swift
//  RxSwiftNetworkTest
//
//  Created by 이민재 on 7/1/24.
//

import Foundation

struct DataModel: Decodable {
    let events: Events
}

struct Events: Decodable {
    let type: String
    let actor: Actor
    let createdTime: String
    
    enum CodingKeys: String, CodingKey {
        case createdTime = "created_at"
        case type
        case actor
    }
}

struct Actor: Decodable {
    let userName: String
    let userIconUrl: String
    
    enum CodingKeys: String, CodingKey {
        case userName = "login"
        case userIconUrl = "avatar_url"
    }
}
