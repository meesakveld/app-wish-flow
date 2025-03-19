//
//  NotificationsView.swift
//  WishFlow
//
//  Created by Mees Akveld on 18/03/2025.
//

import SwiftUI

struct NotificationsView: View {
    @StateObject var vm: NotificationsViewModel = NotificationsViewModel()
    @EnvironmentObject var alertManager: AlertManager
    @EnvironmentObject var navigationManager: NavigationManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                
                // MARK: - Title
                HStack(alignment: .center) {
                    Text("Notifications")
                        .multilineTextAlignment(.center)
                        .style(textStyle: .title(.h1), color: .cForeground)
                }
                
                // MARK: Loading placeholders
                if vm.notificationsIsLoading.isLoading() {
                    VStack(spacing: 15) {
                        ForEach(0...2, id: \.self) { _ in
                            NotificationCard(notification: Notification()) { _, _ in }
                                .loadingEffect(true)
                        }
                    }
                }
                
                // MARK: Content
                if (vm.notifications.isEmpty ? !vm.notificationsIsLoading.isInLoadingState() : !vm.notificationsIsLoading.isLoading()) && !vm.notificationsHasError {
                    VStack(spacing: 15) {
                        ForEach(vm.notifications, id: \.documentId) { notification in
                            NotificationCard(notification: notification) { status, eventInvite in
                                switch status {
                                case .accepted:
                                    await vm.updateEventInviteStatus(eventInviteDocumentId: eventInvite.documentId, status: .accepted)
                                    navigationManager.navigate(to: .event(documentId: (eventInvite.event?.documentId ?? ""), isShowingInvitesSheet: false))
                                case .denied:
                                    await vm.updateEventInviteStatus(eventInviteDocumentId: eventInvite.documentId, status: .denied)
                                default:
                                    break
                                }
                            }
                            .task {
                                if !notification.isRead { await vm.updateNotificationAsRead(documentId: notification.documentId) }
                            }
                        }
                    }
                }
                
                // MARK: Error handler
                if vm.notificationsHasError {
                    FeedbackMessage(
                        image: "error",
                        text: "Whoops! That didn’t work—try again later!"
                    ) {
                        Button {
                            Task {
                                await vm.getNotifications(isLoading: $vm.notificationsIsLoading)
                            }
                        } label: {
                            HStack {
                                Image(systemName: "arrow.clockwise.circle")
                                
                                Text("Refresh")
                            }
                            .style(textStyle: .text(.regular), color: .cOrange)
                        }
                    }
                }
            }
            .padding(.horizontal)
            .frame(maxWidth: .infinity)
        }
        .background(Color.cBackground)
        .task {
            await vm.getNotifications(isLoading: $vm.notificationsIsLoading)
        }
        .refreshable {
            Task { await vm.getNotifications(isLoading: $vm.notificationsIsLoading) }
        }
    }
}

#Preview {
    NavigationStack {
        NavigationLink("", value: true)
            .navigationDestination(isPresented: .constant(true)) {
                NotificationsView()
                    .environmentObject(AlertManager())
                    .environmentObject(NavigationManager())
            }
    }
}

