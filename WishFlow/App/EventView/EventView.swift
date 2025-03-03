//
//  EventView.swift
//  WishFlow
//
//  Created by Mees Akveld on 26/02/2025.
//

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
        case info, myWishes, gifties
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
}

struct EventView: View {
    let documentId: String
    @EnvironmentObject var alertManager: AlertManager
    @ObservedObject var vm: EventViewModel = EventViewModel()
    
    @State var showAllParticipants: Bool = false
    @State var spacingParticipants: CGFloat = -15
    
    var body: some View {
        ScrollView {
            // MARK: - Error handling for when event is not found
            if vm.eventHasError {
                VStack {
                    Spacer()
                    
                    HStack {
                        Spacer()
                        FeedbackMessage(
                            image: "error",
                            text: "Whoops! We can't find the event you are looking for — try again later!"
                        ) {
                            Button {
                                Task {
                                    await vm.getEvent(documentId: documentId, isLoading: $vm.eventIsLoading)
                                }
                            } label: {
                                HStack {
                                    Image(systemName: "arrow.clockwise.circle")
                                    Text("Refresh")
                                }
                                .style(textStyle: .text(.regular), color: .cOrange)
                            }
                        }
                        Spacer()
                    }
                    
                    Spacer()
                }
                .frame(width: .infinity ,height: .infinity)
            }
            
            // MARK: - Event
            if !vm.eventHasError {
                VStack(spacing: 30) {
                    
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
                        DropEffect {
                            HStack(spacing: 0) {
                                // Always visible
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
                                
                                // Visible when the user has the role repicient or owner (also receives gifts)
                                if vm.eventUserRole == .owner || vm.eventUserRole == .recipient {
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
                                }
                                
                                // Visible when the user has the role participant or eventType equals to oneToOne (everyone receives and gives gifts)
                                if vm.eventUserRole == .participant || vm.event?.eventType == .oneToOne {
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
                                        .onAppear {
                                            print(vm.event?.eventType == .oneToOne)
                                        }
                                }
                            }
                            .style(textStyle: .text(.medium), color: .cBlack)
                            .frame(maxWidth: .infinity)
                            .frame(height: 45)
                        }
                        
                    }
                    
                    // MARK: - Info
                    if vm.eventViewSubpage == .info {
                        VStack(spacing: 30) {
                            // MARK: Description
                            Text(
                                vm.event?.description ?? "Lorem ipsum dolor sit amet consectetur. Eros fusce ut ipsum in velit eu eros. Consectetur id enim eleifend eget sit lacus. Laoreet at elit id sodales. Amet viverra Amet viverra amet ipsum suspendisse eget urna."
                            )
                            .style(textStyle: .text(.regular), color: .cForeground)
                            
                            // MARK: Details
                            VStack(alignment: .leading, spacing: 10) {
                                
                                // Eventdate
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
                                    
                                    Text(vm.event?.getMinMaxBudgetText() ?? "€10 - €20")
                                        .style(textStyle: .text(.regular), color: .cBlack)
                                    
                                    Spacer()
                                }
                                
                                // MARK: Deadline adding wishes
                                // Visible when the user has the role repicient or owner (also receives gifts)
                                if vm.eventUserRole == .owner || vm.eventUserRole == .recipient {
                                    HStack(alignment: .center) {
                                        Text("Deadline adding wishes:")
                                            .style(textStyle: .text(.medium), color: .cBlack)
                                        
                                        Text((vm.event?.giftDeadline ?? Date()).dateToStringFormatter(DateFormat: .dd_MMM_yyyy))
                                            .style(textStyle: .text(.regular), color: .cBlack)
                                        
                                        Spacer()
                                    }
                                }
                                
                                // MARK: Deadline selecting wishes
                                // Visible when the user has the role participant or eventType equals to oneToOne (everyone receives and gives gifts)
                                if vm.eventUserRole == .owner || vm.eventUserRole == .participant || vm.event?.eventType == .oneToOne {
                                    HStack(alignment: .center) {
                                        Text("Deadline selecting wishes:")
                                            .style(textStyle: .text(.medium), color: .cBlack)
                                        
                                        Text((vm.event?.claimDeadline ?? Date()).dateToStringFormatter(DateFormat: .dd_MMM_yyyy))
                                            .style(textStyle: .text(.regular), color: .cBlack)
                                        
                                        Spacer()
                                    }
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
                    
                    
                    // MARK: - My Wishes
                    if vm.eventViewSubpage == .myWishes {
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("My wishes")
                                    .style(textStyle: .text(.bold), color: .cForeground)
                                
                                Text("You haven't added any wishes")
                                    .style(textStyle: .textSmall(.regular), color: .cForeground)
                            }
                            
                            Spacer()
                            
                            HStack {
                                Text("Select wishes")
                                Image(systemName: "arrow.up.right")
                            }
                            .style(textStyle: .textSmall(.regular), color: .cForeground)
                        }
                    }
                    
                    
                    // MARK: - Gifties
                    if vm.eventViewSubpage == .gifties {
                        VStack(spacing: 30) {
                            HStack(alignment: .top) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Gifties")
                                        .style(textStyle: .text(.bold), color: .cForeground)
                                    
                                    Text("Select the gift(s) you will give.")
                                        .style(textStyle: .textSmall(.regular), color: .cForeground)
                                }
                                
                                Spacer()
                            }
                            
                            if let participants = vm.event?.eventParticipants {
                                ForEach(participants, id: \.documentId) { participant in
                                    ZStack {
                                        DropEffect {
                                            Text("dfsgdh")
                                                .frame(height: 200)
                                                .frame(maxWidth: .infinity)
                                                .background { Color.cBlue }
                                        }
                                        
                                        VStack {
                                            HStack {
                                                HStack(spacing: 5) {
                                                    Avatar(
                                                        image: participant.user?.avatar,
                                                        width: 22
                                                    )
                                                    .padding(4)

                                                    Text("\(participant.user?.firstname ?? "") \(participant.user?.lastname ?? "")")
                                                        .style(textStyle: .textSmall(.regular), color: .cBlack)
                                                        .padding(.trailing, 10)
                                                }
                                                .padding(1)
                                                .background(Color.cOrange)
                                                .cornerRadius(25)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 25)
                                                        .stroke(Color.cBlack, lineWidth: 1.5)
                                                )
                                                
                                                Spacer()
                                            }
                                            Spacer()
                                        }
                                        .offset(x: 15, y: -10)
                                    }
                                }
                            }
                        }
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
                                do {
                                    try vm.addCalendarEvent(
                                        title: event.title,
                                        date: event.eventDate,
                                        description: event.title + "\n\n" + event.description,
                                        url: URL(string: "wishflow://events/\(event.documentId)")
                                    )
                                    alertManager.present(Alert(
                                        title: "Succes!",
                                        message: "\(event.title) was successfully added to your calendar on \(event.eventDate.dateToStringFormatter(DateFormat: .EEEE_comma_dd_MMMM_yyyy))!"
                                    ))
                                } catch (let error) {
                                    alertManager.present(Alert(
                                        title: "Something went wrong!",
                                        message: error.localizedDescription
                                    ))
                                }
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
                    .environmentObject(AlertManager())
            }
    }
}
