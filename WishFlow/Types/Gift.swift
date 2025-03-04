//
//  Gift.swift
//  WishFlow
//
//  Created by Mees Akveld on 24/02/2025.
//

import Foundation
import StrapiSwift

struct Gift: Codable {
    var id: Int
    var documentId: String
    var title: String
    var description: String
    var image: StrapiImage?
    var url: String?
    var giftLimit: Int
    var price: Price?
    var events: [Event]?
    var giftClaims: [GiftClaim]?
    var user: User?
    var createdAt: Date
    var updatedAt: Date
    var publishedAt: Date

    enum CodingKeys: String, CodingKey {
        case id, documentId, title, description, image, url, giftLimit, price, events, giftClaims, user, createdAt, updatedAt, publishedAt
    }
    
    init() {
        self.id = 1
        self.documentId = UUID().uuidString
        self.title = "Cadeau"
        self.description = "Cadeau description about the gift"
        self.image = nil
        self.url = "https://www.google.com"
        self.giftLimit = 1
        self.price = Price(id: 1, amount: 10.5, currency: Currency())
        self.events = nil
        self.giftClaims = nil
        self.user = nil
        self.createdAt = Date()
        self.updatedAt = Date()
        self.publishedAt = Date()
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(Int.self, forKey: .id)
        documentId = try container.decode(String.self, forKey: .documentId)
        title = try container.decode(String.self, forKey: .title)
        description = try container.decode(String.self, forKey: .description)
        giftLimit = try container.decode(Int.self, forKey: .giftLimit)

        url = try container.decodeIfPresent(String.self, forKey: .url)
        price = try container.decodeIfPresent(Price.self, forKey: .price)
        image = try container.decodeIfPresent(StrapiImage.self, forKey: .image)
        events = try container.decodeIfPresent([Event].self, forKey: .events)
        giftClaims = try container.decodeIfPresent([GiftClaim].self, forKey: .giftClaims)
        user = try container.decodeIfPresent(User.self, forKey: .user)

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
        try container.encode(giftLimit, forKey: .giftLimit)

        try container.encodeIfPresent(url, forKey: .url)
        try container.encodeIfPresent(price, forKey: .price)
        try container.encodeIfPresent(image, forKey: .image)
        try container.encodeIfPresent(events, forKey: .events)
        try container.encodeIfPresent(giftClaims, forKey: .giftClaims)
        try container.encodeIfPresent(user, forKey: .user)

        let formatter = DateFormatter.iso8601WithMilliseconds
        try container.encode(formatter.string(from: createdAt), forKey: .createdAt)
        try container.encode(formatter.string(from: updatedAt), forKey: .updatedAt)
        try container.encode(formatter.string(from: publishedAt), forKey: .publishedAt)
    }
}
