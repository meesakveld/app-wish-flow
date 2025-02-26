//
//  EventsViewModel.swift
//  WishFlow
//
//  Created by Mees Akveld on 26/02/2025.
//

import Foundation
import SwiftUI
import StrapiSwift

@MainActor
class EventsViewModel: ObservableObject {
    let user: User? = AuthenticationManager.shared.user
    
    @Published var events: [Event] = []
    @Published var eventsIsLoading: LoadingState = .preparingToLoad
    @Published var eventsHasError: Bool = false
    
    @Published var search: String = ""
    @Published var sortEventDate: SortOperator = .descending { didSet { activeSort = .date } }
    @Published private(set) var activeSort: ActiveSortOperator = .date
    
    enum ActiveSortOperator {
        case date
    }
    
    func getEvents(isLoading: Binding<LoadingState>) async {
        eventsHasError = false
        setLoading(value: isLoading, .isLoading)
        do {
            let strapiResponse = try await EventManager.shared.getUpcomingEventsWithUserIdWithSearchSortedByEventDateAndPagination(
                userId: user!.id,
                search: search,
                sortEventDate: sortEventDate,
                page: 1,
                pageSize: 100
            )
            events = strapiResponse.data
        } catch {
            eventsHasError = true
            print(error)
        }
        setLoading(value: isLoading, .finished)
    }
    
}
