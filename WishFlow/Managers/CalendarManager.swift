//
//  CalendarManager.swift
//  WishFlow
//
//  Created by Mees Akveld on 27/02/2025.
//

import Foundation
import EventKit

enum CalendarError: Error, LocalizedError {
    case accessDenied
    case accessRestricted
    case failedToSave(String)
    
    var errorDescription: String? {
        switch self {
        case .accessDenied:
            return "Calendar access was denied. Please enable permissions in settings."
        case .accessRestricted:
            return "Calendar access is restricted. You may not be able to add events."
        case .failedToSave(let reason):
            return "Failed to save event: \(reason)"
        }
    }
}

struct CalendarEvent: Identifiable {
    let id: UUID = UUID()
    let title: String
    let date: Date
    let description: String
    let url: URL?
}

@MainActor
final class CalendarManager: ObservableObject, Sendable {
    
    static let shared = CalendarManager()
    
    private init() { }
    
    /// External function to add an event
    func addCalendarEvent(_ event: CalendarEvent, completion: @escaping (Result<Void, CalendarError>) -> Void) {
        let eventStore = EKEventStore()
        
        checkCalendarAuthorizationStatus(eventStore: eventStore) { result in
            switch result {
            case .success:
                do {
                    try self.saveEvent(to: eventStore, event: event)
                    completion(.success(()))
                } catch let error as CalendarError {
                    completion(.failure(error))
                } catch {
                    completion(.failure(.failedToSave(error.localizedDescription)))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    /// Private function to check and request calendar authorization
    private func checkCalendarAuthorizationStatus(eventStore: EKEventStore, completion: @escaping (Result<Void, CalendarError>) -> Void) {
        let status = EKEventStore.authorizationStatus(for: .event)
        
        switch status {
        case .notDetermined:
            eventStore.requestWriteOnlyAccessToEvents { granted, error in
                DispatchQueue.main.async {
                    if granted && error == nil {
                        completion(.success(()))
                    } else {
                        completion(.failure(.accessDenied))
                    }
                }
            }
        case .authorized:
            completion(.success(()))
        case .denied:
            completion(.failure(.accessDenied))
        case .restricted:
            completion(.failure(.accessRestricted))
        default:
            completion(.success(()))
        }
    }
    
    /// Private function that saves the event to the calendar
    private func saveEvent(to eventStore: EKEventStore, event: CalendarEvent) throws {
        let calendarEvent = EKEvent(eventStore: eventStore)
        calendarEvent.title = event.title
        
        let startOfDay = Calendar.current.startOfDay(for: event.date)
        guard let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay) else {
            throw CalendarError.failedToSave("Could not determine the event's end date.")
        }
        
        calendarEvent.startDate = startOfDay
        calendarEvent.endDate = endOfDay
        calendarEvent.isAllDay = true
        if let url = event.url {
            calendarEvent.url = url
        }
        calendarEvent.notes = event.description
        calendarEvent.calendar = eventStore.defaultCalendarForNewEvents
        
        do {
            try eventStore.save(calendarEvent, span: .thisEvent)
            print("✅ Full-day event added to calendar.")
        } catch {
            throw CalendarError.failedToSave(error.localizedDescription)
        }
    }
}
