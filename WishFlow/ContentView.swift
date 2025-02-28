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
    @EnvironmentObject private var alertManager: AlertManager

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
            .alert(alertManager.alert.title, isPresented: $alertManager.isPresenting) {
                alertManager.alert.actions?() ?? AnyView(EmptyView())
            } message: {
                Text(alertManager.alert.message)
            }

        }
    }
}

#Preview {
    ContentView()
        .environmentObject(NavigationManager())
        .environmentObject(AlertManager())
}
