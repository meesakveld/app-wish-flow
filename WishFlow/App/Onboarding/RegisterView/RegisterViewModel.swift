//
//  RegisterViewModel.swift
//  WishFlow
//
//  Created by Mees Akveld on 21/02/2025.
//

import Foundation
import StrapiSwift

class RegisterViewModel: ObservableObject {
    
    func register(email: String, username: String, firstname: String, lastname: String, password: String) async throws {
        try await AuthenticationManager.shared.register(
            email: email,
            username: username,
            firstname: firstname,
            lastname: lastname,
            password: password
        )
    }
    
}
