//
//  EditEventViewModel.swift
//  WishFlow
//
//  Created by Mees Akveld on 11/03/2025.
//

import Foundation
import SwiftUI
import StrapiSwift

@MainActor
class EditEventViewModel: ObservableObject {
    @Published var event: Event? = nil
    @Published var eventIsLoading: LoadingState = .preparingToLoad
    @Published var eventHasError: Bool = false
    
    let user: User? = AuthenticationManager.shared.user
    
    init() {
        if user == nil { Task { await AuthenticationManager.shared.logout() } }
    }
    
    func getEvent(documentId: String, isLoading: Binding<LoadingState>) async {
        eventHasError = false
        setLoading(value: isLoading, .isLoading)
        do {
            let strapiResponse = try await EventManager.shared.getEventByDocumentId(documentId: documentId, userId: user?.id ?? 1)
            event = strapiResponse
        } catch {
            eventHasError = true
            print(error)
        }
        setLoading(value: isLoading, .finished)
    }
    
    func updateEvent(
        documentId: String,
        title: String? = nil,
        description: String? = nil,
        image: UIImage? = nil,
        eventDate: Date? = nil,
        minBudgetAmount: Double? = nil,
        minBudgetCurrency: Currency? = nil,
        maxBudgetAmount: Double? = nil,
        maxBudgetCurrency: Currency? = nil,
        giftDeadline: Date? = nil,
        claimDeadline: Date? = nil
    ) async throws -> Event? {
        // Upload image
        // Delete old image
        if let _ = image, let oldImageId = event?.image?.id {
            try await Strapi.mediaLibrary.files.withId(oldImageId).delete(as: StrapiImage.self)
        }
        
        // Upload new image
        var imageId: Int?
        if let image = image {
            let response = try await Strapi.mediaLibrary.files.uploadImage(image: image)
            imageId = response?.id
        }
        
        // Upload gift
        let event = try await EventManager.shared.updateEventByDocumentId(
            documentId: documentId,
            title: title,
            description: description,
            imageId: imageId,
            eventDate: eventDate,
            minBudgetAmount: minBudgetAmount,
            minBudgetCurrency: minBudgetCurrency,
            maxBudgetAmount: maxBudgetAmount,
            maxBudgetCurrency: maxBudgetCurrency,
            giftDeadline: giftDeadline,
            claimDeadline: claimDeadline
        )
        
        return event
    }
}
