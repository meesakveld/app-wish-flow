//
//  ContentView.swift
//  WishFlow
//
//  Created by Mees Akveld on 03/02/2025.
//

import SwiftUI

struct ContentView: View {
    @State private var navigationPath = NavigationPath()

    var body: some View {
        NavigationStack(path: $navigationPath) {
            WelcomeView()
        }
    }
}

#Preview {
    ContentView()
}
