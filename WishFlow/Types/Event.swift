//
//  Event.swift
//  WishFlow
//
//  Created by Mees Akveld on 24/02/2025.
//

import Foundation
import StrapiSwift

struct Event: Codable, Identifiable {
    var id: Int
    var documentId: String
    var title: String
    var description: String
    var eventDate: Date
    var giftDeadline: Date?
    var claimDeadline: Date?
    var eventType: EventType
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

    init() {
        self.id = 1
        self.documentId = UUID().uuidString
        self.title = "Test Event titel feest"
        self.description = "Test Event Description"
        self.eventDate = Date()
        self.giftDeadline = nil
        self.claimDeadline = nil
        self.eventType = .singleRecipient
        self.image = nil
        self.minBudget = nil
        self.maxBudget = nil
        self.gifts = nil
        self.eventParticipants = nil
        self.giftClaims = nil
        self.eventAssignments = nil
        self.eventInvites = nil
        self.createdAt = Date()
        self.updatedAt = Date()
        self.publishedAt = Date()
    }
    
    enum CodingKeys: String, CodingKey {
        case id, documentId, title, description, eventDate, giftDeadline, claimDeadline, eventType, image, minBudget, maxBudget, gifts, eventParticipants, giftClaims, eventAssignments, eventInvites, createdAt, updatedAt, publishedAt
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(Int.self, forKey: .id)
        documentId = try container.decode(String.self, forKey: .documentId)
        title = try container.decode(String.self, forKey: .title)
        description = try container.decode(String.self, forKey: .description)
        eventType = try container.decode(EventType.self, forKey: .eventType)
        image = try container.decodeIfPresent(StrapiImage.self, forKey: .image)
        minBudget = try container.decodeIfPresent(Price.self, forKey: .minBudget)
        maxBudget = try container.decodeIfPresent(Price.self, forKey: .maxBudget)
        gifts = try container.decodeIfPresent([Gift].self, forKey: .gifts)
        eventParticipants = try container.decodeIfPresent([EventParticipant].self, forKey: .eventParticipants)
        giftClaims = try container.decodeIfPresent([GiftClaim].self, forKey: .giftClaims)
        eventAssignments = try container.decodeIfPresent([EventAssignment].self, forKey: .eventAssignments)
        eventInvites = try container.decodeIfPresent([EventInvite].self, forKey: .eventInvites)
        
        let shortDateFormatter = DateFormatter.shortDate
        eventDate = try decoder.decodeDate(from: container, forKey: .eventDate, using: shortDateFormatter)
        giftDeadline = try decoder.decodeDateIfPresent(from: container, forKey: .giftDeadline, using: shortDateFormatter)
        claimDeadline = try decoder.decodeDateIfPresent(from: container, forKey: .claimDeadline, using: shortDateFormatter)

        let iso8601WithMillisecondsFormatter = DateFormatter.iso8601WithMilliseconds
        createdAt = try decoder.decodeDate(from: container, forKey: .createdAt, using: iso8601WithMillisecondsFormatter)
        updatedAt = try decoder.decodeDate(from: container, forKey: .updatedAt, using: iso8601WithMillisecondsFormatter)
        publishedAt = try decoder.decodeDate(from: container, forKey: .publishedAt, using: iso8601WithMillisecondsFormatter)
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
    
    // MARK: - Utils
    func getMinMaxBudgetText() -> String? {
        // MARK: minBudget and maxBudget are available
        if let minBudget = minBudget?.formatted(), let maxBudget = maxBudget?.formatted() {
            return "\(minBudget) - \(maxBudget)"
        }
        
        // MARK: Only minBudget is available
        if let minBudgetFormatted = minBudget?.formatted() {
            return "Min \(minBudgetFormatted)"
        }
        
        // MARK: Only maxBudget is available
        if let maxBudgetAmount = maxBudget?.formatted() {
            return "Max \(maxBudgetAmount)"
        }
        
        return nil
    }
    
    func getGiftees(userId: Int) -> [EventParticipant] {
        var participants: [EventParticipant] = []
        
        guard let eventParticipants = eventParticipants else {
            return participants
        }
        
        // Filter on participantRole
        participants = eventParticipants.filter({ $0.role == .owner || $0.role == .recipient }).filter({ $0.user?.id != userId })
        
        // Filter on eventAssignment when eventType equals oneToOne
        if eventType == .oneToOne, let eventAssignments = eventAssignments {
            participants = participants.filter { participant in
                return eventAssignments.contains { $0.giver?.id == userId && $0.receiver?.id == participant.user?.id }
            }
        }

        return participants
    }
    
    func getStatus(userId: Int) -> (text: String, sfSymbol: String)? {
        guard self.eventDate.isTodayOrFuture() else { return nil }
        
        // TODAY IS PARTY DAY
        if self.eventDate.isToday() {
            return (text: "Today is party day", sfSymbol: "party.popper")
        }
        
        // SELECT THE GIFTS YOU WOULD LIKE TO RECEIVE
        if let participant = self.eventParticipants?.first(where: { $0.user?.id ?? 0 == userId }),
           participant.role == .owner || participant.role == .recipient,
           self.gifts?.count(where: { ($0.user?.id ?? 0) == userId }) ?? 0 == 0
        {
            return (text: "Select the gifts you would like to receive.", sfSymbol: "checklist")
        }
        
        // SELECT THE GIFTS YOU ARE GOING TO BUY
        if let participant = self.eventParticipants?.first(where: { $0.user?.id ?? 0 == userId }),
           self.giftClaims?.count(where: { ($0.user?.id ?? 0) == userId }) ?? 0 == 0
        {
            if self.eventType == .singleRecipient && participant.role == .owner {} else {
                return (text: "Select the gifts you are going to buy.", sfSymbol: "cart.badge.plus")
            }
        }
        
        // TIME TO BUY THE GIFTS
        if let participant = self.eventParticipants?.first(where: { $0.user?.id ?? 0 == userId }),
           self.giftClaims?.count(where: { ($0.user?.id ?? 0) == userId && $0.giftStatus == .purchased }) ?? 0 == 0 {
            if self.eventType == .singleRecipient && participant.role == .owner {} else {
                return (text: "Time to buy the gifts!", sfSymbol: "cart")
            }
        }
            
        return (text: "You are ready for the event!", sfSymbol: "checkmark")
    }
}

// MARK: - EventType Enum

enum EventType: String, Codable {
    case singleRecipient, groupGifting, oneToOne
}
