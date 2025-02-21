//
//  ContentView.swift
//  WishFlow
//
//  Created by Mees Akveld on 03/02/2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var authManager = AuthenticationManager.shared
    @EnvironmentObject private var navigationManager: NavigationManager

    var body: some View {
        NavigationStack(path: $navigationManager.navigationPath) {
            Group {
                if authManager.isLoggedIn {
                    // General
                    HomeView()
                } else {
                    // Onboarding & Authentication
                    WelcomeView()
                }
            }
            .navigationDestination(for: NavigationManager.NavigationDestination.self) { destination in
                navigationManager.destinationView(for: destination)
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(NavigationManager())
}
