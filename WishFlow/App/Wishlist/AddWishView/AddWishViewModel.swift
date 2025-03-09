//
//  AddWishViewModel.swift
//  WishFlow
//
//  Created by Mees Akveld on 09/03/2025.
//

import Foundation
import SwiftUI
import StrapiSwift

@MainActor
class AddWishViewModel: ObservableObject {
    @Published var tabViewIndex: Int = 0
    @Published var newTabViewIndex: Int = 0 {
        didSet { withAnimation { tabViewIndex = newTabViewIndex }}
    }
    
    let user: User? = AuthenticationManager.shared.user
    
    init() {
        if user == nil { AuthenticationManager.shared.logout() }
    }
    
    func addWish(
        title: String,
        description: String,
        url: String,
        imageURL: String?,
        imageUIImage: UIImage?,
        giftLimit: Int,
        priceAmount: Double,
        priceCurrencyDocumentId: String
    ) async throws -> Gift? {
        // Upload image
        var image: StrapiImage? = nil
        if let imageUIImage = imageUIImage {
            image = try await Strapi.mediaLibrary.files.uploadImage(image: imageUIImage)
        } else if let imageURL = imageURL {
            image = try await Strapi.mediaLibrary.files.uploadImage(fileURL: URL(string: imageURL)!)
        }
        
        var wish: Gift? = nil
        if let imageId = image?.id {
            // Upload gift
            wish = try await GiftManager.shared.addGift(
                title: title,
                description: description,
                url: url,
                imageId: imageId,
                giftLimit: giftLimit,
                priceAmount: priceAmount,
                priceCurrencyDocumentId: priceCurrencyDocumentId,
                userId: user?.id ?? 1
            )
        }
        return wish
    }
    
}
