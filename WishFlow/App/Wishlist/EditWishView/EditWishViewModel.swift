//
//  EditWishViewModel.swift
//  WishFlow
//
//  Created by Mees Akveld on 10/03/2025.
//

import Foundation
import SwiftUI
import StrapiSwift

@MainActor
class EditWishViewModel: ObservableObject {
    @Published var wish: Gift? = nil
    @Published var wishIsLoading: LoadingState = .preparingToLoad
    @Published var wishHasError: Bool = false
    
    let user: User? = AuthenticationManager.shared.user
    
    init() {
        if user == nil { Task { await AuthenticationManager.shared.logout() } }
    }
    
    func getWish(documentId: String, isLoading: Binding<LoadingState>) async {
        wishHasError = false
        setLoading(value: isLoading, .isLoading)
        do {
            let strapiResponse = try await GiftManager.shared.getGiftByDocumentId(documentId: documentId, userId: user?.id ?? 1)
            wish = strapiResponse
        } catch {
            wishHasError = true
            print(error)
        }
        setLoading(value: isLoading, .finished)
    }
    
    func updateWish(documentId: String, title: String?, description: String?, image: UIImage?, url: String?, price: Double?, priceCurrencyDocumentId: String?, giftLimit: Int?, isLoading: Binding<LoadingState>) async throws {
        wishHasError = false
        setLoading(value: isLoading, .isLoading)
        do {
            // —— Update image ——
            // Delete old image
            if let _ = image, let oldImageId = wish?.image?.id {
                try await Strapi.mediaLibrary.files.withId(oldImageId).delete(as: StrapiImage.self)
            }
            
            // Upload new image
            var imageId: Int?
            if let image = image {
                let response = try await Strapi.mediaLibrary.files.uploadImage(image: image)
                imageId = response?.id
            }
            
            // —— Update gift ——
            try await GiftManager.shared.updateGiftByDocumentId(
                documentId: documentId,
                title: title,
                description: description,
                url: url,
                imageId: imageId,
                giftLimit: giftLimit,
                priceAmount: price,
                priceCurrencyDocumentId: priceCurrencyDocumentId
            )
        } catch {
            wishHasError = true
            print(error)
        }
        setLoading(value: isLoading, .finished)
    }
    
}
