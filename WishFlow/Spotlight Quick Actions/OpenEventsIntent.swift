//
//  OpenEventsIntent.swift
//  WishFlow
//
//  Created by Mees Akveld on 14/03/2025.
//

import Foundation
import AppIntents
import SwiftUI

struct OpenEventsIntent: AppIntent {
    static var title: LocalizedStringResource = "Open Events"
    
    static var description = IntentDescription("Opens the Wishflow events page.")

    static var openAppWhenRun: Bool = true
    
    @MainActor
    func perform() async throws -> some IntentResult {
        guard let url = URL(string: "wishflow://events") else {
            throw OpenEventsError.invalidURL
        }
        await UIApplication.shared.open(url)
        return .result()
    }
}

// Optioneel: definieer een specifieke error
enum OpenEventsError: Error {
    case invalidURL
}
