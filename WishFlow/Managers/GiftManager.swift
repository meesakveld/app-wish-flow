//
//  GiftManager.swift
//  WishFlow
//
//  Created by Mees Akveld on 04/03/2025.
//

import Foundation
import StrapiSwift

@MainActor
final class GiftManager: ObservableObject, Sendable {
    
    static let shared = GiftManager()
    
    private init () { }
    
    // MARK: - Requests
    
    private let giftCollection: CollectionQuery = Strapi.contentManager.collection("gifts")
    
    func getGiftsWithUserIdWithSearchAndFilterBasedOnDateAndPrice(
        userId: Int,
        search: String,
        sortGiftDate: SortOperator?,
        sortGiftPrice: SortOperator?
    ) async throws -> [Gift] {
        var query = giftCollection
            .populate("image")
            .populate("price") { price in
                price.populate("currency")
            }
            .filter("[user][id]", operator: .equal, value: userId)
            .filter("[title]", operator: .containsInsensitive, value: search)
        
        if let sortGiftDate = sortGiftDate {
            query = query.sort(by: "createdAt", order: sortGiftDate)
        }
        
        if let sortGiftPrice = sortGiftPrice {
            query = query.sort(by: "[price][amount]", order: sortGiftPrice)
        }

        let response = try await query
            .getDocuments(as: [Gift].self)
        
        return response.data
    }
    
    func getGiftByDocumentId(documentId: String, userId: Int) async throws -> Gift {
        let response = try await giftCollection
            .withDocumentId(documentId)
            .populate("image")
            .populate("price") { price in
                price.populate("currency")
            }
            .populate("events") { event in
                event.populate("image")
            }
            .populate("user")
            .populate("giftClaims")
            .filterGroup(type: .or, { group in
                // Check if gift is equal to entered userId OR enteredUserId is included in an event where the gift is assigned to.
                group.filter("[user][id]", operator: .equal, value: userId)
                group.filter("[events][eventParticipants][user][id]", operator: .includedIn, value: userId)
            })
            .getDocument(as: Gift.self)
        
        return response.data
    }
    
}
