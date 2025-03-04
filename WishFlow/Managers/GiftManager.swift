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
    
    func getGiftsWithUserId(userId: Int) async throws -> [Gift] {
        let response = try await giftCollection
            .populate("image")
            .populate("price") { price in
                price.populate("currency")
            }
            .filter("[user][id]", operator: .includedIn, value: userId)
            .getDocuments(as: [Gift].self)
        
        return response.data
    }
    
    
}
