//
//  EventManager.swift
//  WishFlow
//
//  Created by Mees Akveld on 24/02/2025.
//

import Foundation
import StrapiSwift

@MainActor
final class EventManager: ObservableObject, Sendable {
    
    static let shared = EventManager()
    
    private init () { }
    
    // MARK: - GET REQUESTS
    
    private let eventCollection: CollectionQuery = Strapi.contentManager.collection("events")
    
    private func eventsCollectionQueryWithAllPopulations() async throws -> CollectionQuery {
        return eventCollection
            .populate("image")
            .populate("minBudget") { minBudget in
                minBudget.populate("currency")
            }
            .populate("maxBudget") { maxBudget in
                maxBudget.populate("currency")
            }
            .populate("gifts")
            .populate("eventParticipants") { eventParticipants in
                eventParticipants.populate("user")
            }
            .populate("giftClaims")
            .populate("eventAssignments")
            .populate("eventInvites")
    }
    
    func getUpcomingEventsWithUserId(userId: Int, limit: Int = 3) async throws -> [Event] {
        let currentDate = Date().dateToStringFormatter(DateFormat: .yyyy_MM_dd)
        
        let response = try await eventCollection
            .populate("image")
            .filter("[eventParticipants][user][id]", operator: .includedIn, value: userId)
            .filter("[eventDate]", operator: .greaterThanOrEqual, value: currentDate)
            .paginate(limit: limit)
            .getDocuments(as: [Event].self)
        
        return response.data
    }
    
    func getEventsWithUserIdWithSearchSortedByEventDateAndPagination(
        userId: Int,
        search: String,
        sortEventDate: SortOperator,
        page: Int,
        pageSize: Int
    ) async throws -> StrapiResponse<[Event]> {
        let response = try await eventCollection
            .populate("image")
            .filter("[eventParticipants][user][id]", operator: .includedIn, value: userId)
            .filter("[title]", operator: .containsInsensitive, value: search)
            .sort(by: "eventDate", order: sortEventDate)
            .paginate(page: page, pageSize: pageSize)
            .getDocuments(as: [Event].self)
        
        return response
    }
    
    func getEventByDocumentId(documentId: String, userId: Int) async throws -> Event {
        let response = try await eventCollection
            .withDocumentId(documentId)
            .filter("[eventParticipants][user][id]", operator: .equal, value: userId)
            .populate("image")
            .populate("minBudget") { minBudget in
                minBudget.populate("currency")
            }
            .populate("maxBudget") { maxBudget in
                maxBudget.populate("currency")
            }
            .populate("eventParticipants") { eventParticipants in
                eventParticipants.populate("user") { user in
                    user.populate("avatar")
                }
            }
            .populate("eventInvites")
            .getDocument(as: Event.self)
        
        return response.data
    }
    
    
    // MARK: - POST REQUESTS
    @discardableResult
    func addEvent(
        userId: Int,
        title: String,
        description: String,
        imageId: Int,
        eventDate: Date,
        eventType: EventType,
        minBudgetAmount: Double? = nil,
        minBudgetCurrency: Currency? = nil,
        maxBudgetAmount: Double? = nil,
        maxBudgetCurrency: Currency? = nil,
        giftDeadline: Date? = nil,
        claimDeadline: Date? = nil
    ) async throws -> Event? {
        // —— Upload event ——
        var data: [String: AnyCodable] = [
            "title": .string(title),
            "description": .string(description),
            "image": .int(imageId),
            "eventDate": .string(eventDate.dateToStringFormatter(DateFormat: .RFC3339)),
            "eventType": .string(eventType.rawValue)
        ]
        if let minBudgetAmount = minBudgetAmount, let minBudgetCurrency = minBudgetCurrency {
            data["minBudget"] = .dictionary([
                "amount": .double(minBudgetAmount),
                "currency": .string(minBudgetCurrency.documentId)
            ])
        }
        if let maxBudgetAmount = maxBudgetAmount, let maxBudgetCurrency = maxBudgetCurrency {
            data["maxBudget"] = .dictionary([
                "amount": .double(maxBudgetAmount),
                "currency": .string(maxBudgetCurrency.documentId)
            ])
        }
        if let giftDeadline = giftDeadline {
            data["giftDeadline"] = .string(giftDeadline.dateToStringFormatter(DateFormat: .RFC3339))
        }
        if let claimDeadline = claimDeadline {
            data["claimDeadline"] = .string(claimDeadline.dateToStringFormatter(DateFormat: .RFC3339))
        }
        
        let eventResponse = try await eventCollection.postData(StrapiRequestBody(data), as: Event.self)
                
        // —— Add eventParticipant for owner ——
        try await Strapi.contentManager.collection("event-participants").postData(StrapiRequestBody([
            "user": .int(userId),
            "event": .string(eventResponse.data.documentId),
            "role": .string("owner")
        ]), as: EventParticipant.self)
        
        return eventResponse.data
    }
    
    func deleteEventByDocumentId(documentId: String, userId: Int) async throws {
        let event = try await eventCollection
            .withDocumentId(documentId)
            .filter("[eventParticipants][user][id]", operator: .equal, value: userId)
            .populate("image")
            .populate("eventParticipants")
            .populate("giftClaims")
            .populate("eventAssignments")
            .populate("eventInvites")
            .getDocument(as: Event.self)
        
        // Delete event
        try await eventCollection
            .withDocumentId(documentId)
            .delete()
        
        // Delete image
        if let imageId = event.data.image?.id {
            try await Strapi.mediaLibrary.files.withId(imageId).delete(as: StrapiImage.self)
        }
        
        // Delete eventParticipants (if their are any)
        if let participants = event.data.eventParticipants {
            for participant in participants {
                try await Strapi.contentManager.collection("event-participants").withDocumentId(participant.documentId).delete()
            }
        }
        
        // Delete giftClaims (if their are any)
        if let claims = event.data.giftClaims {
            for claim in claims {
                try await Strapi.contentManager.collection("gift-claims").withDocumentId(claim.documentId).delete()
            }
        }
        
        // Delete eventAssignments (if their are any)
        if let assignments = event.data.eventAssignments {
            for assignment in assignments {
                try await Strapi.contentManager.collection("event-assignments").withDocumentId(assignment.documentId).delete()
            }
        }
        
        // Delete eventInvites (if their are any)
        if let invites = event.data.eventInvites {
            for invite in invites {
                try await Strapi.contentManager.collection("event-invites").withDocumentId(invite.documentId).delete()
            }
        }
    }
    
    
    // MARK: - Utils
    func getUserParticipantRole(event: Event, userId: Int) -> EventParticipantRole? {
        guard let participants = event.eventParticipants else { return nil }
        
        if let participant = participants.first(where: { $0.user?.id == userId }) {
            return participant.role
        }
        return nil
    }
    
}
