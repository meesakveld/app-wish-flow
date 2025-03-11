//
//  InvitePeopleToEventViewModel.swift
//  WishFlow
//
//  Created by Mees Akveld on 11/03/2025.
//

import Foundation
import SwiftUI
import StrapiSwift

@MainActor
class InvitePeopleToEventViewModel: ObservableObject {
    let user: User? = AuthenticationManager.shared.user
    
    @Published var event: Event? = nil
    @Published var eventIsLoading: LoadingState = .preparingToLoad
    @Published var eventHasError: Bool = false
    
    @Published var participants: [EventParticipant] = []
    @Published var eventInvites: [EventInvite] = []
    
    @Published var eventInvitesIsLoading: [String : LoadingState] = [:]
    @Published var eventInvitesHasError: [String : Bool] = [:]
    
    func initEvent(documentId: String, isLoading: Binding<LoadingState>) async {
        eventHasError = false
        setLoading(value: isLoading, .isLoading)
        do {
            // Get Event
            let strapiResponse = try await EventManager.shared.getEventByDocumentId(documentId: documentId, userId: user?.id ?? 0)
            event = strapiResponse
            
            // Event participants
            if let participants = strapiResponse.eventParticipants {
                self.participants = participants
            }
            
            // Event invites
            if let invites = strapiResponse.eventInvites {
                self.eventInvites = invites
            }
        } catch {
            eventHasError = true
            print(error)
        }
        setLoading(value: isLoading, .finished)
    }
    
    func addEventInvite(email: String, eventDocumentId: String) async throws -> EventInvite {
        let result = try await Strapi.contentManager.collection("event-invites")
            .postData(StrapiRequestBody([
                "invitedUserEmail": .string(email),
                "event": .string(eventDocumentId)
            ]), as: EventInvite.self)
        return result.data
    }
    
    func deleteEventInvite(inviteDocumentId: String) async {
        eventInvitesIsLoading[inviteDocumentId] = .isLoading
        do {
            try await Strapi.contentManager.collection("event-invites")
                .withDocumentId(inviteDocumentId)
                .delete()
        } catch {
            print(error)
        }
        eventInvitesIsLoading[inviteDocumentId] = .finished
    }
    
}
