//
//  SelectWishesToGiveViewModel.swift
//  WishFlow
//
//  Created by Mees Akveld on 12/03/2025.
//

import Foundation
import SwiftUI
import StrapiSwift

@MainActor
class SelectWishesToGiveViewModel: ObservableObject {
    let user: User? = AuthenticationManager.shared.user
    
    @Published var event: Event? = nil
    @Published var eventIsLoading: LoadingState = .preparingToLoad
    @Published var eventHasError: Bool = false
    
    @Published var wishes: [Gift] = []
    @Published var wishesIsLoading: LoadingState = .preparingToLoad
    @Published var wishesHasError: Bool = false
    
    @Published var selectedGiftsIds: [String] = []
    
    func initEvent(documentId: String, isLoading: Binding<LoadingState>) async {
        eventHasError = false
        setLoading(value: isLoading, .isLoading)
        do {
            // Get wish
            let strapiResponse = try await EventManager.shared.getEventByDocumentId(documentId: documentId, userId: user?.id ?? 0)
            event = strapiResponse
            
            // Add eventClaims
            if let giftClaims = event?.giftClaims {
                selectedGiftsIds = []
                for claim in giftClaims {
                    if let gift = claim.gift {
                        selectedGiftsIds.append(gift.documentId)
                    }
                }
            }
        } catch {
            eventHasError = true
            print(error)
        }
        setLoading(value: isLoading, .finished)
    }
    
    func initWishes(eventDocumentId: String, receiverUserId: Int, isLoading: Binding<LoadingState>) async {
        wishesHasError = false
        setLoading(value: isLoading, .isLoading)
        do {
            // Get events
            let strapiResponse = try await GiftManager.shared.getGiftsAskedForEventByUserId(eventDocumentId: eventDocumentId, receiverUserId: receiverUserId, userId: user?.id ?? 0)
            wishes = strapiResponse
        } catch {
            wishesHasError = true
            print(error)
        }
        setLoading(value: isLoading, .finished)
    }
    
    func updateEventGiftClaims(eventDocumentId: String, selectedGiftsIds: [String], wishes: [Gift], isLoading: Binding<LoadingState>) async {
        setLoading(value: isLoading, .preparingToLoad)
        do {
            // Get giftClaims where user equals userId, event equals event
            let giftClaims = try await Strapi.contentManager.collection("gift-claims")
                .populate("gift")
                .filter("[user][id]", operator: .equal, value: user?.id ?? 0)
                .filter("[event][documentId]", operator: .equal, value: eventDocumentId)
                .getDocuments(as: [GiftClaim].self)
            
            // Loop over the wishes
            for wish in wishes {
                // Check if there is an giftClaim for the wish
                if let giftClaim = giftClaims.data.first(where: { $0.gift?.documentId == wish.documentId }) {
                    // YES? -> Check if the id of the selectedGiftsIds
                    if !selectedGiftsIds.contains(wish.documentId) {
                        // NO? -> Delete giftClaim
                        try await Strapi.contentManager.collection("gift-claims").withDocumentId(giftClaim.documentId).delete()
                    }
                } else {
                    // NO? -> Check if the id of the selectedGiftsIds
                    if selectedGiftsIds.contains(wish.documentId) {
                        // YES? -> Add giftClaim
                        try await Strapi.contentManager.collection("gift-claims").postData(StrapiRequestBody([
                            "user": .int(user?.id ?? 0),
                            "gift": .string(wish.documentId),
                            "event": .string(eventDocumentId)
                        ]), as: GiftClaim.self)
                    }
                }
            }
        } catch {
            eventHasError = true
            print(error)
        }
        setLoading(value: isLoading, .finished)
    }
}
