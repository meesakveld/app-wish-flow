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
    @Published var upcomingEventsIsLoading: LoadingState = .isLoading
    @Published var upcomingEventsHasError: Bool = false
    
    let user: User? = AuthenticationManager.shared.user
    
    init() {
        if user == nil { Task { await AuthenticationManager.shared.logout() } }
    }
    
    func getUpcomingEvents(isLoading: Binding<LoadingState>) async {
        upcomingEventsHasError = false
        setLoading(value: isLoading, .isLoading)
        do {
            if let userId = user?.id {
                upcomingEvents = try await EventManager.shared.getUpcomingEventsWithUserId(userId: userId)
            }
        } catch {
            upcomingEventsHasError = true
            print(error)
        }
        setLoading(value: isLoading, .finished)
    }
}
