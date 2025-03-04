//
//  WishlistViewModel.swift
//  WishFlow
//
//  Created by Mees Akveld on 04/03/2025.
//

import Foundation
import StrapiSwift
import SwiftUI

@MainActor
class WishlistViewModel: ObservableObject {
    let user: User? = AuthenticationManager.shared.user
    
    @Published var wishes: [Gift] = []
    @Published var wishesIsLoading: LoadingState = .preparingToLoad
    @Published var wishesHasError: Bool = false
    
    @Published var search: String = ""
    @Published var sortWishesDate: SortOperator = .descending { didSet { activeSort = .date } }
    @Published var sortWishesPrice: SortOperator = .descending { didSet { activeSort = .price } }
    @Published private(set) var activeSort: ActiveSortOperator = .date
    
    enum ActiveSortOperator {
        case date, price
    }
    
    func getWishes(isLoading: Binding<LoadingState>) async {
        wishesHasError = false
        setLoading(value: isLoading, .isLoading)
        do {
            wishes = try await GiftManager.shared.getGiftsWithUserIdWithSearchAndFilterBasedOnDateAndPrice(
                userId: user?.id ?? 1,
                search: search,
                sortGiftDate: activeSort == .date ? sortWishesDate : nil,
                sortGiftPrice: activeSort == .price ? sortWishesPrice : nil
            )
        } catch {
            wishesHasError = true
            print(error)
        }
        setLoading(value: isLoading, .finished)
    }
}
