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
            .filter("[user][id]", operator: .includedIn, value: userId)
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
    
    
}
