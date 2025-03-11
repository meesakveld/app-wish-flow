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
        }
    }
    
    enum NavigationDestination: Hashable {
        case home
        case welcome
        case events
        case event(documentId: String, isShowingInvitesSheet: Bool)
        case wishList
        case wish(documentId: String)
    }
}
