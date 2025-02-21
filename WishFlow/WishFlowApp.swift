//
//  WishFlowApp.swift
//  WishFlow
//
//  Created by Mees Akveld on 03/02/2025.
//

import SwiftUI
import StrapiSwift

@main
struct WishFlowApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var navigationManager = NavigationManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(navigationManager)
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        Task {
            Strapi.configure(
                baseURL: "https://" + (Bundle.main.infoDictionary?["STRAPI_BASE_URL"] as? String ?? ""),
                token: Bundle.main.infoDictionary?["STRAPI_TOKEN"] as? String
            )
        }
        return true
    }
}
