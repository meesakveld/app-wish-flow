//
//  EventViewModel.swift
//  WishFlow
//
//  Created by Mees Akveld on 04/03/2025.
//

import Foundation
import SwiftUI

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
}
