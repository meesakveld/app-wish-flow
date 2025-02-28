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
    var actions: (() -> AnyView)?
    
    init(title: String, message: String) {
        self.title = title
        self.message = message
    }
    
    init(title: String, message: String, _ actions: @escaping () -> AnyView) {
        self.title = title
        self.message = message
        self.actions = actions
    }
    
}

class AlertManager: ObservableObject {
    @Published var isPresenting = false
    @Published var alert: Alert = Alert(title: "", message: "")
    
    func present(_ alert: Alert) {
        self.alert = alert
        self.isPresenting = true
    }
}
