//
//  GiftAssignment.swift
//  WishFlow
//
//  Created by Mees Akveld on 24/02/2025.
//

import Foundation

struct EventAssignment: Codable {
    var id: Int
    var giver: User?
    var receiver: User?
    var event: Event?
    var documentId: String
    var createdAt: Date
    var updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id, documentId, giver, receiver, event, createdAt, updatedAt
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(Int.self, forKey: .id)
        documentId = try container.decode(String.self, forKey: .documentId)
        
        giver = try container.decodeIfPresent(User.self, forKey: .giver)
        receiver = try container.decodeIfPresent(User.self, forKey: .receiver)
        event = try container.decodeIfPresent(Event.self, forKey: .event)
        
        let formatter = DateFormatter.iso8601WithMilliseconds
        createdAt = try decoder.decodeDate(from: container, forKey: .createdAt, using: formatter)
        updatedAt = try decoder.decodeDate(from: container, forKey: .updatedAt, using: formatter)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(documentId, forKey: .documentId)
        
        try container.encodeIfPresent(giver, forKey: .giver)
        try container.encodeIfPresent(receiver, forKey: .receiver)
        try container.encodeIfPresent(event, forKey: .event)
        
        let formatter = DateFormatter.iso8601WithMilliseconds
        try container.encode(formatter.string(from: createdAt), forKey: .createdAt)
        try container.encode(formatter.string(from: updatedAt), forKey: .updatedAt)
    }
}
