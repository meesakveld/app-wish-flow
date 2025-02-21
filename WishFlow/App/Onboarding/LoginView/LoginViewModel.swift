//
//  LoginViewModel.swift
//  WishFlow
//
//  Created by Mees Akveld on 21/02/2025.
//

import Foundation

class LoginViewModel: ObservableObject {
    
    func login(identifier: String, password: String) async throws {
        try await AuthenticationManager.shared.login(identifier: identifier, password: password)
    }
    
}
