//
//  AddWishToEventsViewModel.swift
//  WishFlow
//
//  Created by Mees Akveld on 10/03/2025.
//

import Foundation
import SwiftUI

@MainActor
class AddWishToEventsViewModel: ObservableObject {
    let user: User? = AuthenticationManager.shared.user
    
    @Published var wish: Gift? = nil
    @Published var wishIsLoading: LoadingState = .preparingToLoad
    @Published var wishHasError: Bool = false
    
    @Published var events: [Event] = []
    @Published var eventsIsLoading: LoadingState = .preparingToLoad
    @Published var eventsHasError: Bool = false
    
    @Published var selectedEventsIds: [String] = []
    
    func initWish(documentId: String, isLoading: Binding<LoadingState>) async {
        wishHasError = false
        setLoading(value: isLoading, .isLoading)
        do {
            // Get wish
            let strapiResponse = try await GiftManager.shared.getGiftByDocumentId(documentId: documentId, userId: user?.id ?? 1)
            wish = strapiResponse
            
            // Add selectEventsId
            if let events = wish?.events {
                selectedEventsIds = []
                for event in events {
                    selectedEventsIds.append(event.documentId)
                }
            }
        } catch {
            wishHasError = true
            print(error)
        }
        setLoading(value: isLoading, .finished)
    }
    
    func initEvents(isLoading: Binding<LoadingState>) async {
        eventsHasError = false
        setLoading(value: isLoading, .isLoading)
        do {
            // Get events
            let strapiResponse = try await EventManager.shared.getUpcomingEventsWithUserId(
                userId: user!.id,
                limit: -1
            )
            events = strapiResponse
        } catch {
            eventsHasError = true
            print(error)
        }
        setLoading(value: isLoading, .finished)
    }
    
    func updateGiftWishEventsAssignment(documentId: String, events: [String], isLoading: Binding<LoadingState>) async {
        setLoading(value: isLoading, .preparingToLoad)
        do {
            try await GiftManager.shared.updateGiftByDocumentId(documentId: documentId, events: events)
        } catch {
            wishHasError = true
            print(error)
        }
        setLoading(value: isLoading, .finished)
    }
}
