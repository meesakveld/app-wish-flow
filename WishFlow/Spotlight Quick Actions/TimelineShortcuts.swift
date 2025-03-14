//
//  TimelineShortcuts.swift
//  WishFlow
//
//  Created by Mees Akveld on 14/03/2025.
//

import Foundation
import AppIntents

struct TimelineShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: OpenWistlistIntent(),
            phrases: [
                "Open wishlist in \(.applicationName)",
                "Open my wishlist in \(.applicationName)",
                "Open my wishes in \(.applicationName)",
            ],
            shortTitle: "Wishlist",
            systemImageName: "gift"
        )
        
        AppShortcut(
            intent: OpenEventsIntent(),
            phrases: [
                "Open events in \(.applicationName)",
                "Open my events in \(.applicationName)",
                "Open the parties in \(.applicationName)",
            ],
            shortTitle: "Events",
            systemImageName: "party.popper"
        )
        
        AppShortcut(
            intent: OpenBuylistIntent(),
            phrases: [
                "Open buylist in \(.applicationName)",
                "Open my buylist in \(.applicationName)",
                "Open the list of gifts I need to buy in \(.applicationName)",
            ],
            shortTitle: "Buylist",
            systemImageName: "list.clipboard"
        )
    }

    static var shortcutTileColor: ShortcutTileColor = .blue
}
