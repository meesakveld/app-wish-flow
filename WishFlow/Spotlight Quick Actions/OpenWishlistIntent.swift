//
//  OpenEventsIntent.swift
//  WishFlow
//
//  Created by Mees Akveld on 14/03/2025.
//

import Foundation
import AppIntents
import SwiftUI

struct OpenWistlistIntent: AppIntent {
    static var title: LocalizedStringResource = "Open wishlist"
    
    static var description = IntentDescription("Opens the Wishflow wishlist.")

    static var openAppWhenRun: Bool = true
    
    @MainActor
    func perform() async throws -> some IntentResult {
        guard let url = URL(string: "wishflow://wishlist") else {
            throw OpenWishlistError.invalidURL
        }
        await UIApplication.shared.open(url)
        return .result()
    }
}

// Optioneel: definieer een specifieke error
enum OpenWishlistError: Error {
    case invalidURL
}
