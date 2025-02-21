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
//        case .detail(let id):
//            DetailView(id: id).navigationBarBackButtonHidden()
        }
    }
    
    enum NavigationDestination: Hashable {
        case home
        case welcome
        // case detail(id: Int)
    }
}
