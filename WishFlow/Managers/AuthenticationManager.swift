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
        
        // Add device token
        Strapi.useTokenOnce(token: login.jwt)
        await addDeviceToken(authStrapiToken: login.jwt, forUserId: login.user.id)
    }
    
    func register(email: String, username: String, firstname: String, lastname: String, password: String) async throws {
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
        
        // Add device token
        await addDeviceToken(authStrapiToken: register.jwt, forUserId: register.user.id)
    }
    
    func logout() async {
        // Remove device token
        await removeDeviceToken()
        
        // Reset values
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
    
    // MARK: - DEVICE TOKENS
    private func addDeviceToken(authStrapiToken: String, forUserId userId: Int) async {
        do {
            guard let token = UserDefaults.standard.string(forKey: "apnsDeviceToken") else {
                print("No saved device token found")
                throw StrapiSwiftError.badResponse(statusCode: 400, message: "No saved device token found")
            }
            
            Strapi.useTokenOnce(token: authStrapiToken)
            try await Strapi.authentication
                .local
                .me(extendUrl: "/device-token", requestType: .PUT, data: StrapiRequestBody([
                    "deviceToken": .string(token)
                ]), as: Bool.self)
        } catch {
            print(error)
        }
    }
    
    
    private func removeDeviceToken() async {
        do {
            // Retrieve the stored device token from UserDefaults
            guard let token = UserDefaults.standard.string(forKey: "apnsDeviceToken") else {
                print("No saved device token found")
                throw StrapiSwiftError.badResponse(statusCode: 400, message: "No saved device token found")
            }
            
            try await Strapi.authentication.local
                .me(extendUrl: "/device-token/\(token)", requestType: .DELETE, as: Bool.self)
        } catch {
            print(error)
        }
    }

}
