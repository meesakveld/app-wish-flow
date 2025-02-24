//
//  Event.swift
//  WishFlow
//
//  Created by Mees Akveld on 24/02/2025.
//

import Foundation
import StrapiSwift

struct Event: Codable {
    var id: Int
    var documentId: String
    var title: String
    var description: String
    var eventDate: String
    var giftDeadline: String
    var claimDeadline: String
    var eventType: String
    var image: StrapiImage?
    var minBudget: Price?
    var maxBudget: Price?
    var gifts: [Gift]?
    var eventParticipants: [EventParticipant]?
    var giftClaims: [GiftClaim]?
    var eventAssignments: [EventAssignment]?
    var eventInvites: [EventInvite]?
    var createdAt: Date
    var updatedAt: Date
    var publishedAt: Date

    enum CodingKeys: String, CodingKey {
        case id, documentId, title, description, eventDate, giftDeadline, claimDeadline, eventType, image, minBudget, maxBudget, gifts, eventParticipants, giftClaims, eventAssignments, eventInvites, createdAt, updatedAt, publishedAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(Int.self, forKey: .id)
        documentId = try container.decode(String.self, forKey: .documentId)
        title = try container.decode(String.self, forKey: .title)
        description = try container.decode(String.self, forKey: .description)
        eventDate = try container.decode(String.self, forKey: .eventDate)
        giftDeadline = try container.decode(String.self, forKey: .giftDeadline)
        claimDeadline = try container.decode(String.self, forKey: .claimDeadline)
        eventType = try container.decode(String.self, forKey: .eventType)
        image = try container.decodeIfPresent(StrapiImage.self, forKey: .image)
        minBudget = try container.decodeIfPresent(Price.self, forKey: .minBudget)
        maxBudget = try container.decodeIfPresent(Price.self, forKey: .maxBudget)
        gifts = try container.decodeIfPresent([Gift].self, forKey: .gifts)
        eventParticipants = try container.decodeIfPresent([EventParticipant].self, forKey: .eventParticipants)
        giftClaims = try container.decodeIfPresent([GiftClaim].self, forKey: .giftClaims)
        eventAssignments = try container.decodeIfPresent([EventAssignment].self, forKey: .eventAssignments)
        eventInvites = try container.decodeIfPresent([EventInvite].self, forKey: .eventInvites)

        let formatter = DateFormatter.iso8601WithMilliseconds
        createdAt = try decoder.decodeDate(from: container, forKey: .createdAt, using: formatter)
        updatedAt = try decoder.decodeDate(from: container, forKey: .updatedAt, using: formatter)
        publishedAt = try decoder.decodeDate(from: container, forKey: .publishedAt, using: formatter)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(id, forKey: .id)
        try container.encode(documentId, forKey: .documentId)
        try container.encode(title, forKey: .title)
        try container.encode(description, forKey: .description)
        try container.encode(eventDate, forKey: .eventDate)
        try container.encode(giftDeadline, forKey: .giftDeadline)
        try container.encode(claimDeadline, forKey: .claimDeadline)
        try container.encode(eventType, forKey: .eventType)
        try container.encodeIfPresent(image, forKey: .image)
        try container.encodeIfPresent(minBudget, forKey: .minBudget)
        try container.encodeIfPresent(maxBudget, forKey: .maxBudget)
        try container.encodeIfPresent(gifts, forKey: .gifts)
        try container.encodeIfPresent(eventParticipants, forKey: .eventParticipants)
        try container.encodeIfPresent(giftClaims, forKey: .giftClaims)
        try container.encodeIfPresent(eventAssignments, forKey: .eventAssignments)
        try container.encodeIfPresent(eventInvites, forKey: .eventInvites)

        let formatter = DateFormatter.iso8601WithMilliseconds
        try container.encode(formatter.string(from: createdAt), forKey: .createdAt)
        try container.encode(formatter.string(from: updatedAt), forKey: .updatedAt)
        try container.encode(formatter.string(from: publishedAt), forKey: .publishedAt)
    }
}
