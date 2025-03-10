//
//  AlertManager.swift
//  WishFlow
//
//  Created by Mees Akveld on 28/02/2025.
//

import Foundation
import SwiftUI

struct Alert: Identifiable {
    let id = UUID()
    let title: String
    let message: String
    let actions: () -> AnyView
    
    init(title: String, message: String) {
        self.title = title
        self.message = message
        self.actions = { AnyView(EmptyView()) }
    }
    
    init(title: String, message: String, @ViewBuilder actions: @escaping () -> some View) {
        self.title = title
        self.message = message
        self.actions = { AnyView(actions()) }
    }
}

class AlertManager: ObservableObject {
    @Published var isPresenting = false
    @Published var alert: Alert = Alert(title: "", message: "")
    
    func present(_ alert: Alert) {
        DispatchQueue.main.async {
            self.alert = alert
            self.isPresenting = true
        }
    }
}
