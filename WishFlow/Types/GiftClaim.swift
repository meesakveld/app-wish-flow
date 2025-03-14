//
//  GiftClaim.swift
//  WishFlow
//
//  Created by Mees Akveld on 24/02/2025.
//

import Foundation

struct GiftClaim: Codable {
    var id: Int
    var documentId: String
    var user: User?
    var gift: Gift?
    var event: Event?
    var giftStatus: GiftStatus
    var createdAt: Date
    var updatedAt: Date
    
    init() {
        self.id = 1
        self.documentId = UUID().uuidString
        self.user = nil
        self.gift = Gift()
        self.event = Event()
        self.giftStatus = .purchased
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    enum CodingKeys: String, CodingKey {
        case id, documentId, giftStatus, createdAt, updatedAt, user, gift, event
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(Int.self, forKey: .id)
        documentId = try container.decode(String.self, forKey: .documentId)
        giftStatus = try container.decode(GiftStatus.self, forKey: .giftStatus)

        // Decode optional values
        user = try container.decodeIfPresent(User.self, forKey: .user)
        gift = try container.decodeIfPresent(Gift.self, forKey: .gift)
        event = try container.decodeIfPresent(Event.self, forKey: .event)

        let formatter = DateFormatter.iso8601WithMilliseconds
        createdAt = try decoder.decodeDate(from: container, forKey: .createdAt, using: formatter)
        updatedAt = try decoder.decodeDate(from: container, forKey: .updatedAt, using: formatter)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(id, forKey: .id)
        try container.encode(documentId, forKey: .documentId)
        try container.encode(giftStatus, forKey: .giftStatus)

        // Encode optional values if they exist
        try container.encodeIfPresent(user, forKey: .user)
        try container.encodeIfPresent(gift, forKey: .gift)
        try container.encodeIfPresent(event, forKey: .event)

        let formatter = DateFormatter.iso8601WithMilliseconds
        try container.encode(formatter.string(from: createdAt), forKey: .createdAt)
        try container.encode(formatter.string(from: updatedAt), forKey: .updatedAt)
    }
}

// MARK: - GiftStatus Enum

enum GiftStatus: String, Codable {
    case reserved
    case purchased
    
    var title: String {
        switch self {
        case .reserved:
            return "Reserved"
        case .purchased:
            return "Purchased"
        }
    }
}
