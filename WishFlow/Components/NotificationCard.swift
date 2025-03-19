//
//  NotificationCard.swift
//  WishFlow
//
//  Created by Mees Akveld on 19/03/2025.
//

import SwiftUI

struct NotificationCard: View {
    let notification: Notification
    let onInvitationTap: (_ status: EventInviteStatus, _ invite: EventInvite) async -> Void
    
    init(notification: Notification, _ onInvitationTap: @escaping (_ status: EventInviteStatus, _ eventInvite: EventInvite) async -> Void) {
        self.notification = notification
        self.onInvitationTap = onInvitationTap
    }
    
    @State private var isLoading: Bool = false
    
    var body: some View {
        DropEffect {
            HStack(alignment: .firstTextBaseline, spacing: 15) {
                Image(systemName: notification.isRead ? "bell" : "bell.fill")
                
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 10) {
                        
                        HStack {
                            Text(notification.message)
                                .style(textStyle: .text(notification.isRead ? .regular : .medium), color: .cForeground)
                            
                            Spacer()
                        }
                        
                        Text(notification.publishedAt.dateToStringFormatter(DateFormat: .dd_MM_yyyy_mm_hh))
                            .style(textStyle: .textSmall(.medium), color: .cForeground.opacity(0.5))
                        
                    }
                    
                    // MARK: EVENT INVITATION HANDLER
                    if notification.type == .eventInvitation, let eventInvite = notification.eventInvite {
                        
                        if eventInvite.eventInviteStatus == .pending {
                            HStack {
                                Button {
                                    Task {
                                        isLoading = true
                                        await onInvitationTap(.denied, eventInvite)
                                        isLoading = false
                                    }
                                } label: {
                                    Text("Reject")
                                        .padding(4)
                                        .frame(maxWidth: .infinity)
                                        .background(Color.cGray)
                                        .overlay {
                                            RoundedRectangle(cornerRadius: 5)
                                                .stroke(Color.cBlack, lineWidth: 3)
                                                .foregroundStyle(Color.clear)
                                        }
                                        .cornerRadius(5)
                                }
                                
                                Button {
                                    Task {
                                        isLoading = true
                                        await onInvitationTap(.accepted, eventInvite)
                                        isLoading = false
                                    }
                                } label: {
                                    Text("Accept")
                                        .padding(4)
                                        .frame(maxWidth: .infinity)
                                        .background(Color.cGreen)
                                        .cornerRadius(5)
                                        .overlay {
                                            RoundedRectangle(cornerRadius: 5)
                                                .stroke(Color.cBlack, lineWidth: 3)
                                                .foregroundStyle(Color.clear)
                                        }
                                        .cornerRadius(5)
                                }
                            }
                            .style(textStyle: .textSmall(.medium), color: .cBlack)
                            .loadingEffect(isLoading)
                            .frame(maxWidth: .infinity)
                            .cornerRadius(5)
                        }
                        
                        if eventInvite.eventInviteStatus == .accepted || eventInvite.eventInviteStatus == .denied {
                            Text(eventInvite.eventInviteStatus.rawValue)
                                .style(textStyle: .textSmall(.medium), color: .cBlack)
                                .padding(4)
                                .frame(maxWidth: .infinity)
                                .background(Color.cGray)
                                .overlay {
                                    RoundedRectangle(cornerRadius: 5)
                                        .stroke(Color.cBlack, lineWidth: 3)
                                        .foregroundStyle(Color.clear)
                                }
                                .cornerRadius(5)
                                .opacity(0.7)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .padding()
            .background(Color.cYellow)
            
            .onTapGesture {
                // Open url if there is one
                if let urlStr = notification.url, let url = URL(string: urlStr) {
                    DispatchQueue.main.async {
                        UIApplication.shared.open(url, options: [:])
                    }
                }
            }
        }
    }
}
