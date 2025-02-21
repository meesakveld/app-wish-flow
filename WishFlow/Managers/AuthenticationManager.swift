//
//  AuthManager.swift
//  WishFlow
//
//  Created by Mees Akveld on 20/02/2025.
//

import Foundation
import StrapiSwift

@MainActor
final class AuthenticationManager: ObservableObject, Sendable {
    
    static let shared = AuthenticationManager()
    
    @AppSecureStorage("strapiJWT") private var strapiJWT: String?
    @Published var isLoggedIn: Bool = false
    
    private init() {
        isLoggedIn = strapiJWT != nil
    }
    
    func login(identifier: String, password: String) async throws {
        let result = try await Strapi.authentication.local.login(
            identifier: identifier,
            password: password,
            as: User.self
        )
        
        // 🚀 UI expliciet op de hoogte brengen
        strapiJWT = result.jwt
        isLoggedIn = true
    }
    
    func logout() {
        strapiJWT = nil
        isLoggedIn = false
    }
}
