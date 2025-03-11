//
//  AddEventViewModel.swift
//  WishFlow
//
//  Created by Mees Akveld on 11/03/2025.
//

import Foundation
import SwiftUI
import StrapiSwift

@MainActor
class AddEventViewModel: ObservableObject {
    @Published var tabViewIndex: Int = 0
    @Published var newTabViewIndex: Int = 0 {
        didSet { withAnimation { tabViewIndex = newTabViewIndex }}
    }
    
    let user: User? = AuthenticationManager.shared.user
    
    init() {
        if user == nil { AuthenticationManager.shared.logout() }
    }
    
    func addEvent(
        title: String,
        description: String,
        image: UIImage,
        eventDate: Date,
        eventType: EventType,
        minBudgetAmount: Double? = nil,
        minBudgetCurrency: Currency? = nil,
        maxBudgetAmount: Double? = nil,
        maxBudgetCurrency: Currency? = nil,
        giftDeadline: Date? = nil,
        claimDeadline: Date? = nil
    ) async throws -> Event? {
        // Upload image
        let image = try await Strapi.mediaLibrary.files.uploadImage(image: image)
        
        var event: Event? = nil
        if let imageId = image?.id {
            // Upload gift
            event = try await EventManager.shared.addEvent(
                userId: user?.id ?? 0,
                title: title,
                description: description,
                imageId: imageId,
                eventDate: eventDate,
                eventType: eventType,
                minBudgetAmount: minBudgetAmount,
                minBudgetCurrency: minBudgetCurrency,
                maxBudgetAmount: maxBudgetAmount,
                maxBudgetCurrency: maxBudgetCurrency,
                giftDeadline: giftDeadline,
                claimDeadline: claimDeadline
            )
        }
        return event
    }
    
}
