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
    
    @AppStorageData("user") var user: User?
    @AppSecureStorage("strapiJWT") private var strapiJWT: String?
    @Published var isLoggedIn: Bool = false
    
    private init() {
        isLoggedIn = strapiJWT != nil
    }
    
    func login(identifier: String, password: String) async throws {
        do {
            let login = try await Strapi.authentication.local.login(
                identifier: identifier,
                password: password,
                as: User.self
            )
            
            // Update token
            strapiJWT = login.jwt
            StrapiSwiftManager.shared.updateStrapiToken(login.jwt)
            
            // Get user with avatar and role | Save to user
            Strapi.useTokenOnce(token: login.jwt)
            user = try await Strapi.authentication.local.me(as: User.self)
        } catch {
            logout()
            throw(error)
        }
    }
    
    func register(email: String, username: String, firstname: String, lastname: String, password: String) async throws {
        do {
            // Register user
            let register = try await Strapi.authentication.local.register(
                username: username,
                email: email,
                password: password,
                as: User.self)
            
            // Update StrapiSwift token
            strapiJWT = register.jwt
            StrapiSwiftManager.shared.updateStrapiToken(register.jwt)
            
            // Add firstname and lastname to user account
            Strapi.useTokenOnce(token: register.jwt)
            let data: StrapiRequestBody = StrapiRequestBody([
                "firstname": .string(firstname),
                "lastname": .string(lastname)
            ])
            try await Strapi.authentication.local.updateProfile(data, userId: register.user.id, as: User.self)
            
            // Get user with avatar and role | Save to user
            Strapi.useTokenOnce(token: register.jwt)
            user = try await Strapi.authentication.local.me(as: User.self)
        } catch {
            logout()
            throw(error)
        }
    }
    
    func logout() {
        strapiJWT = nil
        isLoggedIn = false
        
        // Update StrapiSwift token
        StrapiSwiftManager.shared.updateStrapiTokenToDefaultToken()
        
        // Remove user from storage
        user = nil
    }
    
    func updateProfile(
        username: String? = nil,
        firstname: String? = nil,
        lastname: String? = nil,
        email: String? = nil,
        imageId: Int? = nil
    ) async throws -> User? {
        var data: [String: AnyCodable] = [:]
        if let username = username { data["username"] = .string(username) }
        if let firstname = firstname { data["firstname"] = .string(firstname) }
        if let lastname = lastname { data["lastname"] = .string(lastname) }
        if let email = email { data["email"] = .string(email) }
        if let avatar = imageId { data["avatar"] = .int(avatar) }
        
        var responseUser: User? = nil
        if let userId = user?.id {
            let response = try await Strapi.authentication.local.updateProfile(StrapiRequestBody(data), userId: userId, as: User.self)
            user = try await Strapi.authentication.local.me(as: User.self)
            responseUser = response
        } else {
            print("ERROR: Cannot update profile. No user logged in.")
        }
        return responseUser
    }
    
    func updatePassword(currentPassword: String, newPassword: String) async throws {
        try await Strapi.authentication.local.changePassword(currentPassword: currentPassword, newPassword: newPassword, as: User.self)
    }
}
