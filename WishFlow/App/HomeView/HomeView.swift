//
//  HomeView.swift
//  WishFlow
//
//  Created by Mees Akveld on 20/02/2025.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var navigationManager: NavigationManager
    
    var body: some View {
        Text("Hello, World!")
        
        Button("Logout") {
            AuthenticationManager.shared.logout()
            navigationManager.navigate(to: .welcome)
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(NavigationManager())
}
