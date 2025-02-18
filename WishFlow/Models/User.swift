//
//  User.swift
//  WishFlow
//
//  Created by Mees Akveld on 18/02/2025.
//

import Foundation

struct User: Decodable, Sendable {
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
    
    enum CodingKeys: String, CodingKey {
        case id, documentId, firstname, lastname, username, email, confirmed, blocked, provider, createdAt, updatedAt, publishedAt
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
        
        // Use a custom formatter that supports milliseconds
        let formatter = DateFormatter.iso8601WithMilliseconds
        
        createdAt = try Self.decodeDate(from: container, forKey: .createdAt, using: formatter)
        updatedAt = try Self.decodeDate(from: container, forKey: .updatedAt, using: formatter)
        publishedAt = try Self.decodeDate(from: container, forKey: .publishedAt, using: formatter)
    }
    
    // Helperfunctie for parsing date
    private static func decodeDate(from container: KeyedDecodingContainer<CodingKeys>, forKey key: CodingKeys, using formatter: DateFormatter) throws -> Date {
        let dateString = try container.decode(String.self, forKey: key)
        guard let date = formatter.date(from: dateString) else {
            throw DecodingError.dataCorruptedError(forKey: key, in: container, debugDescription: "Invalid date format: \(dateString)")
        }
        return date
    }
}

struct Role {
    
}
