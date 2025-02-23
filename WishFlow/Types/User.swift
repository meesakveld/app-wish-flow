//
//  User.swift
//  WishFlow
//
//  Created by Mees Akveld on 18/02/2025.
//

import Foundation
import StrapiSwift

struct User: Codable {
    let id: Int
    let documentId: String
    let firstname: String?
    let lastname: String?
    let username: String
    let email: String
    let confirmed: Bool
    let blocked: Bool
    let provider: String
    let createdAt: Date
    let updatedAt: Date
    let publishedAt: Date
    let avatar: StrapiImage?
    let role: Role?
    
    enum CodingKeys: String, CodingKey {
        case id, documentId, firstname, lastname, username, email, confirmed, blocked, provider, createdAt, updatedAt, publishedAt, avatar, role
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(Int.self, forKey: .id)
        documentId = try container.decode(String.self, forKey: .documentId)
        firstname = try container.decodeIfPresent(String.self, forKey: .firstname)
        lastname = try container.decodeIfPresent(String.self, forKey: .lastname)
        username = try container.decode(String.self, forKey: .username)
        email = try container.decode(String.self, forKey: .email)
        confirmed = try container.decode(Bool.self, forKey: .confirmed)
        blocked = try container.decode(Bool.self, forKey: .blocked)
        provider = try container.decode(String.self, forKey: .provider)
        avatar = try container.decodeIfPresent(StrapiImage.self, forKey: .avatar)
        role = try container.decodeIfPresent(Role.self, forKey: .role)
        
        // Use a custom formatter that supports milliseconds
        let formatter = DateFormatter.iso8601WithMilliseconds
        
        createdAt = try decoder.decodeDate(from: container, forKey: .createdAt, using: formatter)
        updatedAt = try decoder.decodeDate(from: container, forKey: .updatedAt, using: formatter)
        publishedAt = try decoder.decodeDate(from: container, forKey: .publishedAt, using: formatter)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(documentId, forKey: .documentId)
        try container.encodeIfPresent(firstname, forKey: .firstname)
        try container.encodeIfPresent(lastname, forKey: .lastname)
        try container.encode(username, forKey: .username)
        try container.encode(email, forKey: .email)
        try container.encode(confirmed, forKey: .confirmed)
        try container.encode(blocked, forKey: .blocked)
        try container.encode(provider, forKey: .provider)
        try container.encodeIfPresent(avatar, forKey: .avatar)
        try container.encodeIfPresent(role, forKey: .role)
        
        let formatter = DateFormatter.iso8601WithMilliseconds
        try container.encode(formatter.string(from: createdAt), forKey: .createdAt)
        try container.encode(formatter.string(from: updatedAt), forKey: .updatedAt)
        try container.encode(formatter.string(from: publishedAt), forKey: .publishedAt)
    }
}
