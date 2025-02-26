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
    
    func getUpcomingEventsWithUserId(userId: Int) async throws -> [Event] {
        let currentDate = Date().dateToStringFormatter(DateFormat: .yyyy_MM_dd)
        
        let response = try await eventCollection
            .populate("image")
            .filter("[eventParticipants][user][id]", operator: .includedIn, value: userId)
            .filter("[eventDate]", operator: .greaterThanOrEqual, value: currentDate)
            .paginate(limit: 3)
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
    
    func getEventByDocumentId(documentId: String) async throws -> Event {
        let response = try await eventCollection
            .withDocumentId(documentId)
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
            .getDocument(as: Event.self)
        
        return response.data
    }
    
}
