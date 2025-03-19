//
//  HomeViewModel.swift
//  WishFlow
//
//  Created by Mees Akveld on 25/02/2025.
//

import Foundation
import SwiftUI
import StrapiSwift

@MainActor
class HomeViewModel: ObservableObject {
    @Published var upcomingEvents: [Event] = []
    @Published var upcomingEventsIsLoading: LoadingState = .isLoading
    @Published var upcomingEventsHasError: Bool = false
    
    @Published var hasNewNotifications: Bool = false
    
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
    
    func checkForNewNotifications() async {
        do {            
            let response = try await Strapi.contentManager.collection("notifications")
                .filter("[user][id]", operator: .equal, value: user?.id ?? 0)
                .filter("[isRead]", operator: .equal, value: false)
                .getDocuments(as: [Notification].self)
            
            hasNewNotifications = !response.data.isEmpty
        } catch {
            print(error)
        }
    }
}
