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
        let login = try await Strapi.authentication.local.login(
            identifier: identifier,
            password: password,
            as: User.self
        )
        
        strapiJWT = login.jwt
        isLoggedIn = true
        
        // Update token user for StrapiSwift requests
        StrapiSwiftManager.shared.updateStrapiToken(login.jwt)
    }
    
    func register(email: String, username: String, firstname: String, lastname: String, password: String) async throws {
        // Register user
        let register = try await Strapi.authentication.local.register(
            username: username,
            email: email,
            password: password,
            as: User.self)
        
        // Update StrapiSwift token
        StrapiSwiftManager.shared.updateStrapiToken(register.jwt)

        // Add firstname and lastname to user account
        // TODO: Do this ^
    }
    
    func logout() {
        strapiJWT = nil
        isLoggedIn = false
        
        // Update StrapiSwift token
        StrapiSwiftManager.shared.updateStrapiTokenToDefaultToken()
    }
}
