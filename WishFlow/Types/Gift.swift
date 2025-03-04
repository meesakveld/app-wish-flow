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
    var url: String
    var giftLimit: Int
    var price: Price?
    var event: Event?
    var giftClaims: [GiftClaim]?
    var createdAt: Date
    var updatedAt: Date
    var publishedAt: Date

    enum CodingKeys: String, CodingKey {
        case id, documentId, title, description, image, url, giftLimit, price, event, giftClaims, createdAt, updatedAt, publishedAt
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
        self.event = nil
        self.giftClaims = nil
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
        url = try container.decode(String.self, forKey: .url)

        price = try container.decodeIfPresent(Price.self, forKey: .price)
        image = try container.decodeIfPresent(StrapiImage.self, forKey: .image)
        event = try container.decodeIfPresent(Event.self, forKey: .event)
        giftClaims = try container.decodeIfPresent([GiftClaim].self, forKey: .giftClaims)

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
        try container.encode(url, forKey: .url)

        try container.encodeIfPresent(price, forKey: .price)
        try container.encodeIfPresent(image, forKey: .image)
        try container.encodeIfPresent(event, forKey: .event)
        try container.encodeIfPresent(giftClaims, forKey: .giftClaims)

        let formatter = DateFormatter.iso8601WithMilliseconds
        try container.encode(formatter.string(from: createdAt), forKey: .createdAt)
        try container.encode(formatter.string(from: updatedAt), forKey: .updatedAt)
        try container.encode(formatter.string(from: publishedAt), forKey: .publishedAt)
    }
}
