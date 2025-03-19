//
//  NotificationsViewModel.swift
//  WishFlow
//
//  Created by Mees Akveld on 18/03/2025.
//

import Foundation
import SwiftUI
import StrapiSwift

@MainActor
class NotificationsViewModel: ObservableObject {
    @Published var notifications: [Notification] = []
    @Published var notificationsIsLoading: LoadingState = .preparingToLoad
    @Published var notificationsHasError: Bool = true
    
    let user: User? = AuthenticationManager.shared.user
    
    @Published var eventInviteIsLoading: [String : LoadingState] = [:]
    
    init() {
        if user == nil { Task { await AuthenticationManager.shared.logout() } }
    }
    
    func getNotifications(isLoading: Binding<LoadingState>) async {
        notificationsHasError = false
        setLoading(value: isLoading, .isLoading)
        do {
            let response = try await Strapi.contentManager.collection("notifications")
                .filter("[user][id]", operator: .equal, value: user?.id ?? 0)
                .sort(by: "publishedAt", order: .descending)
                .populate("eventInvite") { invite in
                    invite.populate("event")
                }
                .getDocuments(as: [Notification].self)
            notifications = response.data
        } catch {
            notificationsHasError = true
            print(error)
        }
        setLoading(value: isLoading, .finished)
    }
    
    func updateNotificationAsRead(documentId: String) async {
        do {
            try await Strapi.contentManager.collection("notifications").withDocumentId(documentId)
                .putData(StrapiRequestBody([
                    "isRead": .bool(true)
                ]), as: Notification.self)
        } catch {
            print(error)
        }
    }
    
    func updateEventInviteStatus(eventInviteDocumentId: String, status: EventInviteStatus) async {
        eventInviteIsLoading[eventInviteDocumentId] = .isLoading
        do {
            // Update on Strapi
            try await Strapi.contentManager.collection("event-invites").withDocumentId(eventInviteDocumentId)
                .putData(StrapiRequestBody([
                    "eventInviteStatus": .string(status.rawValue)
                ]), as: EventInvite.self)
            
            // Update status in local array
            if let index = notifications.firstIndex(where: { $0.eventInvite?.documentId == eventInviteDocumentId }) {
                DispatchQueue.main.async {
                    self.notifications[index].eventInvite?.eventInviteStatus = status
                }
            }
        } catch {
            print(error)
        }
        eventInviteIsLoading[eventInviteDocumentId] = .finished
    }
}
