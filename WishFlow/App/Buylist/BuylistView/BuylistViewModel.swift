//
//  BuylistViewModel.swift
//  WishFlow
//
//  Created by Mees Akveld on 14/03/2025.
//

import Foundation
import SwiftUI
import StrapiSwift

@MainActor
class BuylistViewModel: ObservableObject {
    let user: User? = AuthenticationManager.shared.user
    
    @Published var giftClaimsPerEvent: [GiftClaimsPerEvent] = []
    @Published var giftClaimsPerEventIsLoading: LoadingState = .preparingToLoad
    @Published var giftClaimsPerEventHasError: Bool = false
    
    @Published var giftClaimIsLoading: [String: Bool] = [:]
    
    struct GiftClaimsPerEvent {
        let id: String = UUID().uuidString
        let event: Event
        var giftClaims: [GiftClaim]
        
        init(event: Event, giftClaims: [GiftClaim]) {
            self.event = event
            self.giftClaims = giftClaims
        }
        
        init() {
            self.event = Event()
            self.giftClaims = [GiftClaim(), GiftClaim(), GiftClaim() ]
        }
    }
    
    // MARK: - FUNCTIONS
    
    func getGiftClaimsPerEvent(isLoading: Binding<LoadingState>) async {
        giftClaimsPerEventHasError = false
        setLoading(value: isLoading, .isLoading)
        do {
            let currentDate = Date().dateToStringFormatter(DateFormat: .yyyy_MM_dd)
            
            let response = try await Strapi.contentManager.collection("gift-claims")
                .populate("gift") { gift in
                    gift.populate("image")
                    gift.populate("price") { price in
                        price.populate("currency")
                    }
                }
                .populate("event") { event in
                    event.populate("image")
                }
                .filter("[user][id]", operator: .equal, value: user?.id ?? 0)
                .filter("[event][eventDate]", operator: .greaterThanOrEqual, value: currentDate)
                .getDocuments(as: [GiftClaim].self)
                .data
            
            var groupedClaims: [GiftClaimsPerEvent] = []
            
            // Group GiftClaims by Event
            for claim in response {
                if let event = claim.event {
                    if let index = groupedClaims.firstIndex(where: { $0.event.id == event.id }) {
                        // Event already in the array, append GiftClaim
                        groupedClaims[index].giftClaims.append(claim)
                    } else {
                        // New Event, create new grouping
                        let newGroup = GiftClaimsPerEvent(event: event, giftClaims: [claim])
                        groupedClaims.append(newGroup)
                    }
                }
            }
            
            giftClaimsPerEvent = groupedClaims
        } catch {
            giftClaimsPerEventHasError = true
            print(error)
        }
        setLoading(value: isLoading, .finished)
    }
    
    func updateGiftClaimStatus(giftClaimDocumentId: String, newStatus: GiftStatus) async {
        giftClaimIsLoading[giftClaimDocumentId] = true
        do {
            try await Strapi.contentManager.collection("gift-claims")
                .withDocumentId(giftClaimDocumentId)
                .putData(StrapiRequestBody([
                    "giftStatus": .string(newStatus.rawValue)
                ]), as: GiftClaim.self)
            
            if let eventIndex = giftClaimsPerEvent.firstIndex(where: { $0.giftClaims.contains(where: { $0.documentId == giftClaimDocumentId }) }) {
                if let claimIndex = giftClaimsPerEvent[eventIndex].giftClaims.firstIndex(where: { $0.documentId == giftClaimDocumentId }) {
                    giftClaimsPerEvent[eventIndex].giftClaims[claimIndex].giftStatus = newStatus
                }
            }
        } catch {
            print(error)
        }
        giftClaimIsLoading[giftClaimDocumentId] = false
    }
    
    func deleteGiftClaim(giftClaimDocumentId: String) async {
        giftClaimIsLoading[giftClaimDocumentId] = true
        do {
            try await Strapi.contentManager.collection("gift-claims").withDocumentId(giftClaimDocumentId).delete()
            
            giftClaimsPerEvent = giftClaimsPerEvent.compactMap { eventGroup -> GiftClaimsPerEvent? in
                let updatedClaims = eventGroup.giftClaims.filter { $0.documentId != giftClaimDocumentId }
                return updatedClaims.isEmpty ? nil : GiftClaimsPerEvent(event: eventGroup.event, giftClaims: updatedClaims)
            }
            
        } catch {
            print(error)
        }
        giftClaimIsLoading[giftClaimDocumentId] = false
    }
}
