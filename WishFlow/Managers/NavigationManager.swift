//
//  NavigationManager.swift
//  WishFlow
//
//  Created by Mees Akveld on 21/02/2025.
//

import Foundation
import SwiftUI

class NavigationManager: ObservableObject {
    @Published var navigationPath = NavigationPath()
    
    func reset() {
        navigationPath = NavigationPath() // Navigatiepad leegmaken
    }
    
    func back() {
        if !navigationPath.isEmpty {
            navigationPath.removeLast()
        }
    }
    
    func navigate(to destination: NavigationDestination) {
        navigationPath.append(destination)
    }
    
    @ViewBuilder
    func destinationView(for destination: NavigationDestination) -> some View {
        switch destination {
        case .home:
            HomeView().navigationBarBackButtonHidden()
        case .welcome:
            WelcomeView().navigationBarBackButtonHidden()
        case .events:
            EventsView()
        case .event(let documentId, let isShowingInvitesSheet):
            EventView(documentId: documentId, isShowingInvitesSheet: isShowingInvitesSheet)
        case .wishList:
            WishlistView()
        case .wish(let documentId):
            WishView(documentId: documentId)
        case .buylist:
            BuylistView()
        }
    }
    
    func navigate(to url: URL) {
        guard url.scheme == "wishflow" else { return }
        
        let pathComponents = url.pathComponents.filter { !$0.isEmpty }
        let firstComponent = url.host ?? pathComponents.first
        
        guard let firstComponent else { return }
        
        switch firstComponent {
        case "events":
            if let eventId = pathComponents.dropFirst().first {
                navigate(to: .event(documentId: eventId, isShowingInvitesSheet: false))
            } else {
                navigate(to: .events)
            }
        case "wishlist":
            if let wishId = pathComponents.dropFirst().first {
                navigate(to: .wish(documentId: wishId))
            } else {
                navigate(to: .wishList)
            }
        case "welcome":
            navigate(to: .welcome)
        case "home":
            navigate(to: .home)
        case "buylist":
            navigate(to: .buylist)
        default:
            return
        }
    }

    
    enum NavigationDestination: Hashable {
        case home
        case welcome
        case events
        case event(documentId: String, isShowingInvitesSheet: Bool)
        case wishList
        case wish(documentId: String)
        case buylist
    }
}
