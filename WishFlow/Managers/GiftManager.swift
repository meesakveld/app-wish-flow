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
    
    // MARK: - GET REQUESTS
    
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
    
    func getGiftsAskedForEventByUserId(eventDocumentId: String, receiverUserId: Int, userId: Int) async throws -> [Gift] {
        let response = try await giftCollection
            .populate("image")
            .populate("price") { price in
                price.populate("currency")
            }
            .filter("[events][documentId]", operator: .includedIn, value: eventDocumentId)
            .filter("[user][id]", operator: .equal, value: receiverUserId)
            .filter("[events][eventParticipants][user][id]", operator: .includedIn, value: userId)
            .getDocuments(as: [Gift].self)
        
        return response.data
    }
    
    // MARK: - POST REQUESTS
    
    func addGift(
        title: String,
        description: String,
        url: String,
        imageId: Int,
        giftLimit: Int,
        priceAmount: Double,
        priceCurrencyDocumentId: String,
        userId: Int
    ) async throws -> Gift {
        let data: StrapiRequestBody = StrapiRequestBody([
            "title": .string(title),
            "description": .string(description),
            "url": .string(url),
            "image": .int(imageId),
            "giftLimit": .int(giftLimit),
            "price": .dictionary([
                "amount": .double(priceAmount),
                "currency": .string(priceCurrencyDocumentId)
            ]),
            "user": .int(userId)
        ])
        
        let response = try await giftCollection.postData(data, as: Gift.self)
        return response.data
    }
    
    @discardableResult
    func updateGiftByDocumentId(
        documentId: String,
        title: String? = nil,
        description: String? = nil,
        url: String? = nil,
        imageId: Int? = nil,
        giftLimit: Int? = nil,
        priceAmount: Double? = nil,
        priceCurrencyDocumentId: String? = nil,
        events: [String]? = nil
    ) async throws -> Gift {
        var data: [String: AnyCodable] = [:]
        if let title = title { data["title"] = .string(title) }
        if let description = description { data["description"] = .string(description) }
        if let url = url { data["url"] = .string(url) }
        if let imageId = imageId { data["image"] = .int(imageId) }
        if let giftLimit = giftLimit { data["giftLimit"] = .int(giftLimit) }
        if let priceAmount = priceAmount, let priceCurrencyDocumentId = priceCurrencyDocumentId {
            data["price"] = .dictionary([
                "amount": .double(priceAmount),
                "currency": .string(priceCurrencyDocumentId)
            ])
            print("data: \(priceAmount) \(priceCurrencyDocumentId)")
        } else if let priceAmount = priceAmount {
            data["price"] = .dictionary([ "amount": .double(priceAmount) ])
            print("data: \(priceAmount)")
        } else if let priceCurrencyDocumentId = priceCurrencyDocumentId {
            data["price"] = .dictionary([ "currency": .string(priceCurrencyDocumentId) ])
            print("data: \(priceCurrencyDocumentId)")
        }
        if let events = events { data["events"] = .array(events.map({ return .string($0) })) }
        
        let response = try await giftCollection
            .withDocumentId(documentId)
            .putData(StrapiRequestBody(data), as: Gift.self)
        return response.data
    }
    
    func deleteGiftByDocumentId(documentId: String, userId: Int) async throws {
        let gift = try await giftCollection
            .withDocumentId(documentId)
            .filter("[user][id]", operator: .equal, value: userId)
            .populate("image")
            .getDocument(as: Gift.self)
        
        // Delete gift
        try await giftCollection
            .withDocumentId(documentId)
            .delete()
        
        // Delete image
        if let imageId = gift.data.image?.id {
            try await Strapi.mediaLibrary.files.withId(imageId).delete(as: StrapiImage.self)
        }
    }
    
}
