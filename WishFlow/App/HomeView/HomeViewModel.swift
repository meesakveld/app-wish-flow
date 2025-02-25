//
//  HomeViewModel.swift
//  WishFlow
//
//  Created by Mees Akveld on 25/02/2025.
//

import Foundation
import SwiftUI

@MainActor
class HomeViewModel: ObservableObject {
    @Published var upcomingEvents: [Event] = []
    @Published var upcomingEventsIsLoading: LoadingState = .readyToLoad
    @Published var upcomingEventsHasError: Bool = false
    
    let user: User? = AuthenticationManager.shared.user
    
    func getUpcomingEvents(isLoading: Binding<LoadingState>) async {
        upcomingEventsHasError = false
        setLoading(value: isLoading, .isLoading)
        do {
            upcomingEvents = try await EventManager.shared.getUpcomingEventsWithUserId(userId: user!.id)
        } catch {
            upcomingEventsHasError = true
            print(error)
        }
        setLoading(value: isLoading, .finished)
    }
}
