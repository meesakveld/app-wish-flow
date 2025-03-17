//
//  WishViewModel.swift
//  WishFlow
//
//  Created by Mees Akveld on 04/03/2025.
//

import Foundation
import SwiftUI

@MainActor
class WishViewModel: ObservableObject {
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
    
    func deleteWish(documentId: String, isLoading: Binding<LoadingState>) async throws {
        setLoading(value: isLoading, .isLoading)
        do {
            try await GiftManager.shared.deleteGiftByDocumentId(documentId: documentId, userId: user?.id ?? 1)
        } catch {
            setLoading(value: isLoading, .finished)
            throw error
        }
        setLoading(value: isLoading, .finished)
    }
}
