//
//  Currency.swift
//  WishFlow
//
//  Created by Mees Akveld on 24/02/2025.
//

import Foundation

struct Currency: Codable, Identifiable, Equatable {
    var id: Int
    var documentId: String
    var code: String
    var name: String
    var symbol: String
    var createdAt: Date
    var updatedAt: Date
    var publishedAt: Date

    enum CodingKeys: String, CodingKey {
        case id, documentId, code, name, symbol, createdAt, updatedAt, publishedAt
    }
    
    init() {
        self.id = 1
        self.documentId = UUID().uuidString
        self.code = "EUR"
        self.name = "Euro"
        self.symbol = "€"
        self.createdAt = Date()
        self.updatedAt = Date()
        self.publishedAt = Date()
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(Int.self, forKey: .id)
        documentId = try container.decode(String.self, forKey: .documentId)
        code = try container.decode(String.self, forKey: .code)
        name = try container.decode(String.self, forKey: .name)
        symbol = try container.decode(String.self, forKey: .symbol)

        let formatter = DateFormatter.iso8601WithMilliseconds
        createdAt = try decoder.decodeDate(from: container, forKey: .createdAt, using: formatter)
        updatedAt = try decoder.decodeDate(from: container, forKey: .updatedAt, using: formatter)
        publishedAt = try decoder.decodeDate(from: container, forKey: .publishedAt, using: formatter)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(id, forKey: .id)
        try container.encode(documentId, forKey: .documentId)
        try container.encode(code, forKey: .code)
        try container.encode(name, forKey: .name)
        try container.encode(symbol, forKey: .symbol)

        let formatter = DateFormatter.iso8601WithMilliseconds
        try container.encode(formatter.string(from: createdAt), forKey: .createdAt)
        try container.encode(formatter.string(from: updatedAt), forKey: .updatedAt)
        try container.encode(formatter.string(from: publishedAt), forKey: .publishedAt)
    }
}
