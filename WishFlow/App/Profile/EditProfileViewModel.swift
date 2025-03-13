//
//  EditProfileViewModel.swift
//  WishFlow
//
//  Created by Mees Akveld on 13/03/2025.
//

import Foundation
import SwiftUI
import StrapiSwift

@MainActor
class EditProfileViewModel: ObservableObject {
    @Published var user: User? = nil
    @Published var userIsLoading: LoadingState = .preparingToLoad
    @Published var userHasError: Bool = false
    
    @Published var updateProfileIsLoading: LoadingState = .preparingToLoad
    @Published var updatePasswordIsLoading: LoadingState = .preparingToLoad

    func getUser(isLoading: Binding<LoadingState>) async {
        userHasError = false
        setLoading(value: isLoading, .isLoading)
        do {
            user = try await Strapi.authentication.local.me(as: User.self)
        } catch {
            userHasError = true
            print(error)
        }
        setLoading(value: isLoading, .finished)
    }
    
    func updateProfile(
        username: String? = nil,
        firstname: String? = nil,
        lastname: String? = nil,
        email: String? = nil,
        image: UIImage? = nil
    ) async throws -> User? {
        if let _ = image, let oldImageId = user?.avatar?.id {
            try await Strapi.mediaLibrary.files.withId(oldImageId).delete(as: StrapiImage.self)
        }
        
        // Upload new image
        var imageId: Int?
        if let image = image {
            let response = try await Strapi.mediaLibrary.files.uploadImage(image: image)
            imageId = response?.id
        }
        
        return try await AuthenticationManager.shared.updateProfile(username: username, firstname: firstname, lastname: lastname, email: email, imageId: imageId)
    }
    
    func updatePassword(currentPassword: String, newPassword: String, confirmNewPassworm: String) async throws {
        guard currentPassword != newPassword else {
            throw StrapiSwiftError.badResponse(statusCode: 422, message: "New password cannot be equal to current password.")
        }
        
        guard newPassword == confirmNewPassworm else {
            throw StrapiSwiftError.badResponse(statusCode: 422, message: "New password needs to be equal to the confirmation password.")
        }
        
        try await AuthenticationManager.shared.updatePassword(currentPassword: currentPassword, newPassword: newPassword)
    }
}
