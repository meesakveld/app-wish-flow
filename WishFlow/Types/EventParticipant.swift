//
//  EventParticipant.swift
//  WishFlow
//
//  Created by Mees Akveld on 24/02/2025.
//

import Foundation

struct EventParticipant: Codable, Identifiable {
    var id: Int
    var documentId: String
    var user: User?
    var event: Event?
    var role: EventParticipantRole
    var createdAt: Date
    var updatedAt: Date
    var publishedAt: Date

    enum CodingKeys: String, CodingKey {
        case id, documentId, user, event, role, createdAt, updatedAt, publishedAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(Int.self, forKey: .id)
        documentId = try container.decode(String.self, forKey: .documentId)
        role = try container.decode(EventParticipantRole.self, forKey: .role)
        user = try container.decodeIfPresent(User.self, forKey: .user)
        event = try container.decodeIfPresent(Event.self, forKey: .event)

        let formatter = DateFormatter.iso8601WithMilliseconds
        createdAt = try decoder.decodeDate(from: container, forKey: .createdAt, using: formatter)
        updatedAt = try decoder.decodeDate(from: container, forKey: .updatedAt, using: formatter)
        publishedAt = try decoder.decodeDate(from: container, forKey: .publishedAt, using: formatter)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(id, forKey: .id)
        try container.encode(documentId, forKey: .documentId)
        try container.encode(role, forKey: .role)
        try container.encodeIfPresent(user, forKey: .user)
        try container.encodeIfPresent(event, forKey: .event)

        let formatter = DateFormatter.iso8601WithMilliseconds
        try container.encode(formatter.string(from: createdAt), forKey: .createdAt)
        try container.encode(formatter.string(from: updatedAt), forKey: .updatedAt)
        try container.encode(formatter.string(from: publishedAt), forKey: .publishedAt)
    }
}

// MARK: - EventParticipantRole Enum

enum EventParticipantRole: String, Codable {
    case owner, participant, recipient
}
