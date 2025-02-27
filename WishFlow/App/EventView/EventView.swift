//
//  EventView.swift
//  WishFlow
//
//  Created by Mees Akveld on 26/02/2025.
//

import SwiftUI

@MainActor
class EventViewModel: ObservableObject {
    @Published var event: Event? = nil
    @Published var eventIsLoading: LoadingState = .preparingToLoad
    @Published var eventHasError: Bool = false
    
    @Published var eventViewSubpage: eventViewSubpage = .info
    
    func getEvent(documentId: String, isLoading: Binding<LoadingState>) async {
        eventHasError = false
        setLoading(value: isLoading, .isLoading)
        do {
            //            try await Task.sleep(nanoseconds: 20_000_000_000)
            let strapiResponse = try await EventManager.shared.getEventByDocumentId(documentId: documentId)
            event = strapiResponse
        } catch {
            eventHasError = true
            print(error)
        }
        setLoading(value: isLoading, .finished)
    }
    
    enum eventViewSubpage {
        case info, myWishes, gifties
    }
    
    func getBudgetText(event: Event?) -> String? {
        guard let event = event else { return nil }
        
        let minBudgetAmount = event.minBudget?.amount
        let minBudgetCurrency = event.minBudget?.currency?.symbol
        
        let maxBudgetAmount = event.maxBudget?.amount
        let maxBudgetCurrency = event.maxBudget?.currency?.symbol
        
        // MARK: minBudget and maxBudget are available
        if let minBudgetAmount, let minBudgetCurrency, let maxBudgetAmount, let maxBudgetCurrency {
            return "\(minBudgetCurrency) \(minBudgetAmount) - \(maxBudgetCurrency) \(maxBudgetAmount)"
        }
        
        // MARK: Only minBudget is available
        if let minBudgetAmount, let minBudgetCurrency {
            return "\(minBudgetCurrency) \(minBudgetAmount) +"
        }
        
        // MARK: Only maxBudget is available
        if let maxBudgetAmount, let maxBudgetCurrency {
            return "\(maxBudgetCurrency) 0 - \(maxBudgetCurrency) \(maxBudgetAmount)"
        }
        
        return nil
    }
    
    func addCalendarEvent(title: String, date: Date, description: String, url: URL?) {
        // TODO: Handle error and succes
        CalendarManager.shared.addCalendarEvent(CalendarEvent(
            title: title,
            date: date,
            description: description,
            url: url
        )) { result in
            switch result {
            case .success:
                print("Event successfully added to your calendar!")
            case .failure(let error):
                print("❌ Error: \(error.localizedDescription)")
            }
        }
    }
}

struct EventView: View {
    let documentId: String
    @ObservedObject var vm: EventViewModel = EventViewModel()
    
    @State var showAllParticipants: Bool = false
    @State var spacingParticipants: CGFloat = -15
    
    var body: some View {
        ScrollView {
            VStack(spacing: 40) {
                
                // MARK: - Title
                HStack(alignment: .center) {
                    Text(vm.event?.title ?? "Event title")
                        .multilineTextAlignment(.center)
                        .style(textStyle: .title(.h1), color: .cForeground)
                }
                .padding(.horizontal)
                
                
                // MARK: - Image
                VStack(spacing: 12) {
                    
                    DropEffect {
                        ZStack {
                            Color.cYellow
                                .frame(height: 200)
                                .frame(maxWidth: .infinity)
                            
                            if let url = vm.event?.image?.formats?.small?.url {
                                AsyncImage(url: URL(string: url)) { image in
                                    image.resizable()
                                        .scaledToFill()
                                } placeholder: {
                                    ProgressView()
                                }
                                .frame(height: 200)
                                .frame(maxWidth: .infinity)
                            }
                        }
                    }
                    
                    
                    // MARK: - Menu Switcher
                    // TODO: Make dynamic based on role (owner is also an receiver)
                    DropEffect {
                        HStack(spacing: 0) {
                            Text("Info")
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(Color.cPurple)
                                .border(Color.cBlack)
                                .overlay {
                                    if vm.eventViewSubpage == .info {
                                        RoundedRectangle(cornerRadius: 5)
                                            .stroke(Color.cBlack, lineWidth: 1.5)
                                            .background(Color.clear)
                                            .padding(4)
                                    }
                                }
                                .onTapGesture { vm.eventViewSubpage = .info }
                            
                            Text("My wishes")
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(Color.cYellow)
                                .border(Color.cBlack)
                                .overlay {
                                    if vm.eventViewSubpage == .myWishes {
                                        RoundedRectangle(cornerRadius: 5)
                                            .stroke(Color.cBlack, lineWidth: 1.5)
                                            .background(Color.clear)
                                            .padding(4)
                                    }
                                }
                                .onTapGesture { vm.eventViewSubpage = .myWishes }
                            
                            Text("Gifties")
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(Color.cGreen)
                                .border(Color.cBlack)
                                .overlay {
                                    if vm.eventViewSubpage == .gifties {
                                        RoundedRectangle(cornerRadius: 5)
                                            .stroke(Color.cBlack, lineWidth: 1.5)
                                            .background(Color.clear)
                                            .padding(4)
                                    }
                                }
                                .onTapGesture { vm.eventViewSubpage = .gifties }
                        }
                        .style(textStyle: .text(.medium), color: .cBlack)
                        .frame(maxWidth: .infinity)
                        .frame(height: 45)
                    }
                    
                }
                
                // MARK: - Info
                if vm.eventViewSubpage == .info {
                    VStack(spacing: 40) {
                        // MARK: Description
                        Text(
                            vm.event?.description ?? "Lorem ipsum dolor sit amet consectetur. Eros fusce ut ipsum in velit eu eros. Consectetur id enim eleifend eget sit lacus. Laoreet at elit id sodales. Amet viverra Amet viverra amet ipsum suspendisse eget urna."
                        )
                        .style(textStyle: .text(.regular), color: .cForeground)
                        
                        // MARK: Details
                        VStack(alignment: .leading, spacing: 10) {
                            
                            // Eventdate
                            // TODO: Klik? Zet in agenda
                            HStack(alignment: .center) {
                                Text("Eventdate:")
                                    .style(textStyle: .text(.medium), color: .cBlack)
                                
                                Text((vm.event?.eventDate ?? Date()).dateToStringFormatter(DateFormat: .dd_MMM_yyyy))
                                    .style(textStyle: .text(.regular), color: .cBlack)
                                
                                Spacer()
                            }
                            
                            // Budget
                            HStack(alignment: .center) {
                                Text("Budget:")
                                    .style(textStyle: .text(.medium), color: .cBlack)
                                
                                Text(vm.getBudgetText(event: vm.event) ?? "€10 - €20")
                                    .style(textStyle: .text(.regular), color: .cBlack)
                                
                                Spacer()
                            }
                            
                            // Deadline adding wishes
                            // TODO: Klik? Zet in agenda
                            // TODO: Dynamicly shown based on role
                            HStack(alignment: .center) {
                                Text("Deadline adding wishes:")
                                    .style(textStyle: .text(.medium), color: .cBlack)
                                
                                Text((vm.event?.giftDeadline ?? Date()).dateToStringFormatter(DateFormat: .dd_MMM_yyyy))
                                    .style(textStyle: .text(.regular), color: .cBlack)
                                
                                Spacer()
                            }
                            
                            // Deadline selecting wishes
                            // TODO: Klik? Zet in agenda
                            HStack(alignment: .center) {
                                Text("Deadline selecting wishes:")
                                    .style(textStyle: .text(.medium), color: .cBlack)
                                
                                Text((vm.event?.claimDeadline ?? Date()).dateToStringFormatter(DateFormat: .dd_MMM_yyyy))
                                    .style(textStyle: .text(.regular), color: .cBlack)
                                
                                Spacer()
                            }
                        }
                        .frame(maxWidth: .infinity)
                        
                        // MARK: Participants
                        VStack(alignment: .leading) {
                            if let eventParticipants = vm.event?.eventParticipants {
                                if showAllParticipants {
                                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 44), spacing: 15)], spacing: 15) {
                                        ForEach(eventParticipants) { participant in
                                            Menu {
                                                Text("\(participant.user?.firstname ?? "") \(participant.user?.lastname ?? "")")
                                            } label: {
                                                Avatar(image: participant.user?.avatar)
                                            }
                                        }
                                    }
                                    .transition(.opacity)
                                } else {
                                    HStack(spacing: spacingParticipants) {
                                        ForEach(eventParticipants.prefix(4)) { participant in
                                            Avatar(image: participant.user?.avatar)
                                        }
                                        if eventParticipants.count > 4 {
                                            Text("+\(eventParticipants.count - 4)")
                                                .frame(width: 44, height: 44)
                                                .background(Color.cOrange)
                                                .style(textStyle: .text(.regular), color: .cBlack)
                                                .clipShape(Circle())
                                                .overlay(Circle().stroke(Color.cForeground, lineWidth: 2))
                                        }
                                        
                                        Spacer()
                                    }
                                    .transition(.opacity)
                                }
                            }
                        }
                        .animation(.smooth, value: showAllParticipants)
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                spacingParticipants = 20
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: {
                                showAllParticipants = true
                            })
                        }
                        .onDisappear {
                            // Reset participants view
                            showAllParticipants = false
                            spacingParticipants = -15
                        }
                    }
                    .frame(maxHeight: .infinity)
                }
            }
            .loadingEffect(vm.eventIsLoading.isInLoadingState())
            .padding(.horizontal)
            .task {
                await vm.getEvent(documentId: documentId, isLoading: $vm.eventIsLoading)
            }
            .toolbar {
                Menu {
                    
                    // MARK: Add event to calendar
                    Button {
                        if let event = vm.event {
                            vm.addCalendarEvent(
                                title: event.title,
                                date: event.eventDate,
                                description: event.title + "\n\n" + event.description,
                                url: URL(string: "wishflow://events/\(event.documentId)")
                            )
                        }
                    } label: {
                        Label("Add event to calendar", systemImage: "calendar")
                    }
                    
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
                .disabled(vm.event == nil)
            }
        }
        .refreshable {
            Task {
                await vm.getEvent(documentId: documentId, isLoading: $vm.eventIsLoading)
            }
        }
        .background(Color.cBackground.ignoresSafeArea())
    }
}

#Preview {
    NavigationStack {
        NavigationLink("", value: true)
            .navigationDestination(isPresented: .constant(true)) {
                EventView(documentId: "yyi02rmev5oqpgxllz903avf")
            }
    }
}
