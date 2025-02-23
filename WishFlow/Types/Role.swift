//
//  Role.swift
//  WishFlow
//
//  Created by Mees Akveld on 23/02/2025.
//

import Foundation

public struct Role: Codable {
    public var id: Int
    public var documentId: String
    public var name: String
    public var description: String
    public var type: String
    public var createdAt: Date
    public var updatedAt: Date
    public var publishedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id, documentId, name, description, type, createdAt, updatedAt, publishedAt
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(Int.self, forKey: .id)
        documentId = try container.decode(String.self, forKey: .documentId)
        name = try container.decode(String.self, forKey: .name)
        description = try container.decode(String.self, forKey: .description)
        type = try container.decode(String.self, forKey: .type)
        
        // Now calling the common decodeDate helper
        let formatter = DateFormatter.iso8601WithMilliseconds
        createdAt = try decoder.decodeDate(from: container, forKey: .createdAt, using: formatter)
        updatedAt = try decoder.decodeDate(from: container, forKey: .updatedAt, using: formatter)
        publishedAt = try decoder.decodeDate(from: container, forKey: .publishedAt, using: formatter)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(documentId, forKey: .documentId)
        try container.encode(name, forKey: .name)
        try container.encode(description, forKey: .description)
        try container.encode(type, forKey: .type)
        
        // Custom date formatter for encoding
        let formatter = DateFormatter.iso8601WithMilliseconds
        try container.encode(formatter.string(from: createdAt), forKey: .createdAt)
        try container.encode(formatter.string(from: updatedAt), forKey: .updatedAt)
        try container.encode(formatter.string(from: publishedAt), forKey: .publishedAt)
    }
}
