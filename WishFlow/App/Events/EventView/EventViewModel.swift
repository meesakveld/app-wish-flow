//
//  EventViewModel.swift
//  WishFlow
//
//  Created by Mees Akveld on 04/03/2025.
//

import Foundation
import SwiftUI
import StrapiSwift

@MainActor
class EventViewModel: ObservableObject {
    @Published var event: Event? = nil {
        didSet { if let event = event {
            eventUserRole = EventManager.shared.getUserParticipantRole(event: event, userId: user?.id ?? 1)
        } }
    }
    @Published var eventUserRole: EventParticipantRole? = .participant
    
    @Published var eventIsLoading: LoadingState = .preparingToLoad
    @Published var eventHasError: Bool = false
    
    @Published var eventViewSubpage: eventViewSubpage = .info
    
    let user: User? = AuthenticationManager.shared.user
    
    init() {
        if user == nil { AuthenticationManager.shared.logout() }
    }
    
    func getEvent(documentId: String, isLoading: Binding<LoadingState>) async {
        eventHasError = false
        setLoading(value: isLoading, .isLoading)
        do {
            let strapiResponse = try await EventManager.shared.getEventByDocumentId(documentId: documentId, userId: user?.id ?? 1)
            event = strapiResponse
        } catch {
            eventHasError = true
            print(error)
        }
        setLoading(value: isLoading, .finished)
    }
    
    enum eventViewSubpage {
        case info, myWishes, giftees
    }
    
    func addCalendarEvent(title: String, date: Date, description: String, url: URL?) throws {
        var error: CalendarError?
        
        CalendarManager.shared.addCalendarEvent(CalendarEvent(
            title: title,
            date: date,
            description: description,
            url: url
        )) { result in
            switch result {
            case .success:
                break
            case .failure(let errorAddingCalendarEvent):
                error = errorAddingCalendarEvent
            }
        }
        
        if let error = error {
            throw error
        }
    }
    
    func deleteEvent(documentId: String, isLoading: Binding<LoadingState>) async throws {
        setLoading(value: isLoading, .isLoading)
        do {
            try await EventManager.shared.deleteEventByDocumentId(documentId: documentId, userId: user?.id ?? 1)
        } catch {
            setLoading(value: isLoading, .finished)
            throw error
        }
        setLoading(value: isLoading, .finished)
    }
    
    
    // MARK: -
    
    func randomizeGifties(eventDocumentId: String, isLoading: Binding<LoadingState>) async {
        eventHasError = false
        setLoading(value: isLoading, .isLoading)
        do {
            // Get event Particpants
            let participantsData = try await Strapi.contentManager.collection("event-participants")
                .filter("[event][documentId]", operator: .equal, value: eventDocumentId)
                .populate("user")
                .getDocuments(as: [EventParticipant].self)
            
            let participants = participantsData.data.map { $0.user!.id }
            
            guard participants.count > 1 else {
                throw NSError(domain: "Not enough participants", code: 1, userInfo: nil)
            }
            
            // Shuffle the participants
            var shuffledParticipants = participants.shuffled()

            // Ensure no one pulls themselves using a circular shift
            if participants.count > 1 {
                repeat {
                    shuffledParticipants.shuffle()
                } while zip(participants, shuffledParticipants).contains(where: { $0 == $1 })
            }

            // Make the assignments [giver : receiver]
            let assignments = Dictionary(uniqueKeysWithValues: zip(participants, shuffledParticipants))
            
            // assign random
            for (giver, receiver) in assignments {
                try await Strapi.contentManager.collection("event-assignments")
                    .postData(StrapiRequestBody([
                        "giver": .int(giver),
                        "receiver": .int(receiver),
                        "event": .string(eventDocumentId)
                    ]), as: EventAssignment.self)
            }
            
            // Delete all open eventInvites
            let eventInvites = try await Strapi.contentManager.collection("event-invites")
                .filter("[event][documentId]", operator: .equal, value: eventDocumentId)
                .getDocuments(as: [EventInvite].self)
            
            for invite in eventInvites.data {
                try await Strapi.contentManager.collection("event-invites").withDocumentId(invite.documentId).delete()
            }
            
        } catch {
            eventHasError = true
            print(error)
        }
        setLoading(value: isLoading, .finished)
    }
}
