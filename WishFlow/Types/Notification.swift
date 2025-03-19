//
//  Notification.swift
//  WishFlow
//
//  Created by Mees Akveld on 18/03/2025.
//

import Foundation

struct Notification: Codable {
    var id: Int
    var documentId: String
    var user: User? = nil
    var message: String
    var url: String?
    var isRead: Bool
    var type: NotificationType
    var eventInvite: EventInvite? = nil
    var createdAt: Date
    var updatedAt: Date
    var publishedAt: Date

    enum NotificationType: String, Codable {
        case general
        case eventInvitation
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case documentId
        case user
        case message
        case url
        case isRead
        case type
        case eventInvite
        case createdAt
        case updatedAt
        case publishedAt
    }
    
    init() {
        self.id = 1
        self.documentId = UUID().uuidString
        self.user = nil
        self.message = "Lorem ipsum dolor sit amet, consectetur adipiscing elit."
        self.url = nil
        self.isRead = false
        self.type = .general
        self.eventInvite = nil
        self.createdAt = Date()
        self.updatedAt = Date()
        self.publishedAt = Date()
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.documentId = try container.decode(String.self, forKey: .documentId)
        self.user = try container.decodeIfPresent(User.self, forKey: .user)
        self.message = try container.decode(String.self, forKey: .message)
        self.url = try container.decodeIfPresent(String.self, forKey: .url)
        self.isRead = try container.decode(Bool.self, forKey: .isRead)
        self.type = try container.decode(NotificationType.self, forKey: .type)
        self.eventInvite = try container.decodeIfPresent(EventInvite.self, forKey: .eventInvite)
        
        let formatter = DateFormatter.iso8601WithMilliseconds
        createdAt = try decoder.decodeDate(from: container, forKey: .createdAt, using: formatter)
        updatedAt = try decoder.decodeDate(from: container, forKey: .updatedAt, using: formatter)
        publishedAt = try decoder.decodeDate(from: container, forKey: .publishedAt, using: formatter)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(id, forKey: .id)
        try container.encode(documentId, forKey: .documentId)
        try container.encodeIfPresent(user, forKey: .user)
        try container.encode(message, forKey: .message)
        try container.encodeIfPresent(url, forKey: .url)
        try container.encode(isRead, forKey: .isRead)
        try container.encode(type, forKey: .type)
        try container.encodeIfPresent(eventInvite, forKey: .eventInvite)
        
        let formatter = DateFormatter.iso8601WithMilliseconds
        try container.encode(formatter.string(from: createdAt), forKey: .createdAt)
        try container.encode(formatter.string(from: updatedAt), forKey: .updatedAt)
        try container.encode(formatter.string(from: publishedAt), forKey: .publishedAt)
    }
}
