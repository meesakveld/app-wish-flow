//
//  BuylistView.swift
//  WishFlow
//
//  Created by Mees Akveld on 14/03/2025.
//

import SwiftUI

@MainActor
class BuylistViewModel: ObservableObject {
    let user: User? = AuthenticationManager.shared.user
    
    @Published var wishes: [Gift] = []
    @Published var wishesIsLoading: LoadingState = .preparingToLoad
    @Published var wishesHasError: Bool = false
}

struct BuylistView: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    BuylistView()
}
