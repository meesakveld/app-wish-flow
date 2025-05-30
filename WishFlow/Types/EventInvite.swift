//
//  EventInvite.swift
//  WishFlow
//
//  Created by Mees Akveld on 24/02/2025.
//

import Foundation

struct EventInvite: Codable {
    var id: Int
    var documentId: String
    var event: Event?
    var eventInviteStatus: EventInviteStatus
    var invitedUserEmail: String
    var createdAt: Date
    var updatedAt: Date
    var publishedAt: Date

    enum CodingKeys: String, CodingKey {
        case id, documentId, event, eventInviteStatus, invitedUserEmail, createdAt, updatedAt, publishedAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(Int.self, forKey: .id)
        documentId = try container.decode(String.self, forKey: .documentId)
        event = try container.decodeIfPresent(Event.self, forKey: .event)
        eventInviteStatus = try container.decode(EventInviteStatus.self, forKey: .eventInviteStatus)
        invitedUserEmail = try container.decode(String.self, forKey: .invitedUserEmail)

        let formatter = DateFormatter.iso8601WithMilliseconds
        createdAt = try decoder.decodeDate(from: container, forKey: .createdAt, using: formatter)
        updatedAt = try decoder.decodeDate(from: container, forKey: .updatedAt, using: formatter)
        publishedAt = try decoder.decodeDate(from: container, forKey: .publishedAt, using: formatter)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(id, forKey: .id)
        try container.encode(documentId, forKey: .documentId)
        try container.encode(event, forKey: .event)
        try container.encode(eventInviteStatus, forKey: .eventInviteStatus)
        try container.encode(invitedUserEmail, forKey: .invitedUserEmail)

        let formatter = DateFormatter.iso8601WithMilliseconds
        try container.encode(formatter.string(from: createdAt), forKey: .createdAt)
        try container.encode(formatter.string(from: updatedAt), forKey: .updatedAt)
        try container.encode(formatter.string(from: publishedAt), forKey: .publishedAt)
    }
}

// MARK: - EventInviteStatus Enum

enum EventInviteStatus: String, Codable {
    case pending, accepted, denied
}
