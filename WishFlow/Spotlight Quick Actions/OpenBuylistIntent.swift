//
//  OpenEventsIntent.swift
//  WishFlow
//
//  Created by Mees Akveld on 14/03/2025.
//

import Foundation
import AppIntents
import SwiftUI

struct OpenBuylistIntent: AppIntent {
    static var title: LocalizedStringResource = "Open buylist"
    
    static var description = IntentDescription("Opens the Wishflow buylist.")

    static var openAppWhenRun: Bool = true
    
    @MainActor
    func perform() async throws -> some IntentResult {
        guard let url = URL(string: "wishflow://buylist") else {
            throw OpenWishlistError.invalidURL
        }
        await UIApplication.shared.open(url)
        return .result()
    }
}

// Optioneel: definieer een specifieke error
enum OpenBuylistError: Error {
    case invalidURL
}
