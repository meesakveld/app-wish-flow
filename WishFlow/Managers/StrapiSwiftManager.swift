//
//  StrapiSwiftManager.swift
//  WishFlow
//
//  Created by Mees Akveld on 21/02/2025.
//

import Foundation

import StrapiSwift

@MainActor
final class StrapiSwiftManager {
    static let shared = StrapiSwiftManager()
    
    private init() { }
    
    @AppSecureStorage("strapiJWT") private var strapiJWT: String?
    
    private var strapiToken = Bundle.main.infoDictionary?["STRAPI_TOKEN"] as? String
    private var strapiBaseURL: String = "https://" + (Bundle.main.infoDictionary?["STRAPI_BASE_URL"] as? String ?? "")
    
    func configure() {
        var token = strapiToken
        if let strapiJWT = strapiJWT {
            token = strapiJWT
        }
        
        Task {
            Strapi.configure(
                baseURL: strapiBaseURL,
                token: token
            )
        }
    }
    
    func updateStrapiToken(_ token: String) {
        Task {
            Strapi.configure(
                baseURL: strapiBaseURL,
                token: token
            )
        }
    }
    
    func updateStrapiTokenToDefaultToken() {
        Task {
            Strapi.configure(
                baseURL: strapiBaseURL,
                token: strapiToken
            )
        }
    }
    
}
