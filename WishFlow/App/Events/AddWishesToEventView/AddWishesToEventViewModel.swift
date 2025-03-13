//
//  AddWishesToEventViewModel.swift
//  WishFlow
//
//  Created by Mees Akveld on 12/03/2025.
//

import Foundation
import SwiftUI

@MainActor
class AddWishesToEventViewModel: ObservableObject {
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
            
            // Add selectEventsId
            if let wishes = event?.gifts {
                selectedGiftsIds = []
                for wish in wishes {
                    selectedGiftsIds.append(wish.documentId)
                }
            }
        } catch {
            eventHasError = true
            print(error)
        }
        setLoading(value: isLoading, .finished)
    }
    
    func initWishes(isLoading: Binding<LoadingState>) async {
        wishesHasError = false
        setLoading(value: isLoading, .isLoading)
        do {
            // Get events
            let strapiResponse = try await GiftManager.shared.getGiftsWithUserIdWithSearchAndFilterBasedOnDateAndPrice(
                userId: user?.id ?? 0,
                search: "",
                sortGiftDate: .descending,
                sortGiftPrice: nil
            )
            wishes = strapiResponse
        } catch {
            wishesHasError = true
            print(error)
        }
        setLoading(value: isLoading, .finished)
    }
    
    func updateEventGiftAssignment(documentId: String, selectedGiftsIds: [String], isLoading: Binding<LoadingState>) async {
        setLoading(value: isLoading, .preparingToLoad)
        do {
            try await EventManager.shared.updateGiftsForEvent(documentId: documentId, giftsDocumentIds: selectedGiftsIds)
        } catch {
            eventHasError = true
            print(error)
        }
        setLoading(value: isLoading, .finished)
    }
}
