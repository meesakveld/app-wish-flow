//
//  EventView.swift
//  WishFlow
//
//  Created by Mees Akveld on 26/02/2025.
//

import SwiftUI

struct EventView: View {
    let documentId: String
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    @EnvironmentObject var alertManager: AlertManager
    @StateObject var vm: EventViewModel = EventViewModel()
    @ObservedObject var navigationManager: NavigationManager = NavigationManager()
    
    @State var showAllParticipants: Bool = false
    @State var spacingParticipants: CGFloat = -15
    
    @State var isShowingInvitesSheet: Bool = false
    @State var isShowingSelectWishesSheet: Bool = false
    @State var isShowingSelectWishesToGiveSheet: Bool = false
    
    let columns = [
        GridItem(.flexible(), spacing: 15),
        GridItem(.flexible(), spacing: 15)
    ]
    
    init(documentId: String) {
        self.documentId = documentId
    }
    
    init(documentId: String, isShowingInvitesSheet: Bool) {
        self.documentId = documentId
        _isShowingInvitesSheet = State(initialValue: isShowingInvitesSheet)
    }
    
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
                .frame(maxWidth: .infinity, maxHeight: .infinity)
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
                                if vm.eventUserRole == .participant || vm.event?.eventType != .singleRecipient {
                                    Text(vm.event?.eventType == .groupGifting ? "Giftees" : "Giftee")
                                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                                        .background(Color.cGreen)
                                        .border(Color.cBlack)
                                        .overlay {
                                            if vm.eventViewSubpage == .giftees {
                                                RoundedRectangle(cornerRadius: 5)
                                                    .stroke(Color.cBlack, lineWidth: 1.5)
                                                    .background(Color.clear)
                                                    .padding(4)
                                            }
                                        }
                                        .onTapGesture { vm.eventViewSubpage = .giftees }
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
                            HStack {
                                Text(
                                    vm.event?.description ?? "Lorem ipsum dolor sit amet consectetur. Eros fusce ut ipsum in velit eu eros. Consectetur id enim eleifend eget sit lacus. Laoreet at elit id sodales. Amet viverra Amet viverra amet ipsum suspendisse eget urna."
                                )
                                .textSelection(.enabled)
                                .style(textStyle: .text(.regular), color: .cForeground)
                                
                                Spacer()
                            }
                            
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
                                if let budget = vm.event?.getMinMaxBudgetText() {
                                    HStack(alignment: .center) {
                                        Text("Budget:")
                                            .style(textStyle: .text(.medium), color: .cBlack)
                                        
                                        Text(budget)
                                            .style(textStyle: .text(.regular), color: .cBlack)
                                        
                                        Spacer()
                                    }
                                }
                                
                                // MARK: Deadline adding wishes
                                // Visible when the user has the role repicient or owner (also receives gifts)
                                if vm.eventUserRole == .owner || vm.eventUserRole == .recipient, let giftDeadline = vm.event?.giftDeadline {
                                    HStack(alignment: .center) {
                                        Text("Deadline adding wishes:")
                                            .style(textStyle: .text(.medium), color: .cBlack)
                                        
                                        Text(giftDeadline.dateToStringFormatter(DateFormat: .dd_MMM_yyyy))
                                            .style(textStyle: .text(.regular), color: .cBlack)
                                        
                                        Spacer()
                                    }
                                }
                                
                                // MARK: Deadline selecting wishes
                                // Visible when the user has the role participant or eventType equals to oneToOne (everyone receives and gives gifts)
                                if vm.eventUserRole == .owner || vm.eventUserRole == .participant || vm.event?.eventType == .oneToOne, let claimDeadline = vm.event?.claimDeadline {
                                    HStack(alignment: .center) {
                                        Text("Deadline selecting wishes:")
                                            .style(textStyle: .text(.medium), color: .cBlack)
                                        
                                        Text(claimDeadline.dateToStringFormatter(DateFormat: .dd_MMM_yyyy))
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
                        VStack(spacing: 20) {
                            HStack(alignment: .top) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("My wishes")
                                        .style(textStyle: .text(.bold), color: .cForeground)
                                }
                                
                                Spacer()
                                
                                Button {
                                    isShowingSelectWishesSheet.toggle()
                                } label: {
                                    HStack {
                                        Text("Select wishes")
                                            .underline()
                                        
                                        Image(systemName: "arrow.up.right")
                                    }
                                    .style(textStyle: .textSmall(.regular), color: .cForeground)
                                }
                            }
                            .sheet(isPresented: $isShowingSelectWishesSheet) {
                                Task {
                                    await vm.getEvent(documentId: documentId, isLoading: $vm.eventIsLoading)
                                }
                            } content: {
                                AddWishesToEventView(eventDocumentId: documentId)
                            }
                            
                            
                            let gifts = vm.event?.gifts?.filter({ $0.user?.id == vm.user?.id }) ?? []
                            
                            if !gifts.isEmpty {
                                //MARK: Wishes array
                                LazyVGrid(columns: columns, spacing: 15) {
                                    ForEach(gifts, id: \.documentId) { wish in
                                        NavigationLink {
                                            WishView(documentId: wish.documentId)
                                        } label: {
                                            WishCard(wish: wish)
                                        }
                                    }
                                }
                                .frame(maxWidth: .infinity)
                            }
                            
                            if gifts.isEmpty {
                                Text("You haven't added any wishes")
                                    .style(textStyle: .textSmall(.regular), color: .cForeground)
                            }
                        }
                    }
                    
                    
                    // MARK: - Giftees
                    if vm.eventViewSubpage == .giftees {
                        
                        // Visible when eventType equals oneToOne and there are no assignments yet
                        if !(vm.event?.eventType == .oneToOne && (vm.event?.eventAssignments?.count ?? 0) == 0) {
                            
                            VStack(spacing: 40) {
                                HStack(alignment: .top) {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text(vm.event?.eventType == .groupGifting ? "Giftees" : "Giftee")
                                            .style(textStyle: .text(.bold), color: .cForeground)
                                        
                                        Text("Select the gift(s) you will give.")
                                            .style(textStyle: .textSmall(.regular), color: .cForeground)
                                    }
                                    
                                    Spacer()
                                }
                                
                                if let gifties = vm.event?.getGiftees(userId: vm.user?.id ?? 0) {
                                    VStack(spacing: 30) {
                                        ForEach(gifties, id: \.documentId) { giftie in
                                            ZStack {
                                                let participantsWishes = vm.event?.gifts?.filter({ $0.user?.id == giftie.user?.id }) ?? []
                                                
                                                DropEffect {
                                                    VStack(spacing: 20) {
                                                        // No wishes added yet
                                                        if participantsWishes.isEmpty {
                                                            Text("\(giftie.user?.firstname ?? "User") has not added gifts here yet.")
                                                                .style(textStyle: .textSmall(.regular), color: .cBlack)
                                                                .frame(height: 200)
                                                                .frame(maxWidth: .infinity)
                                                                .padding(.horizontal, 15)
                                                        }
                                                        
                                                        // Wishes
                                                        if !participantsWishes.isEmpty {
                                                            ScrollView(.horizontal, showsIndicators: false) {
                                                                LazyHStack(spacing: 15) {
                                                                    ForEach(participantsWishes, id: \.documentId) { wish in
                                                                        NavigationLink {
                                                                            WishView(documentId: wish.documentId)
                                                                        } label: {
                                                                            ZStack {
                                                                                WishCard(wish: wish)
                                                                                    .frame(width: 130, height: 200)
                                                                                
                                                                                if let giftClaims = vm.event?.giftClaims, giftClaims.contains(where: { $0.gift?.documentId == wish.documentId && $0.user?.id == vm.user?.id }) {
                                                                                    VStack {
                                                                                        HStack {
                                                                                            CheckCircle(isChecked: true, { })
                                                                                                .padding(1.5)
                                                                                                .background(Color.cBlack)
                                                                                                .cornerRadius(.infinity)
                                                                                                .offset(x: -5)
                                                                                            
                                                                                            Spacer()
                                                                                        }
                                                                                        Spacer()
                                                                                    }
                                                                                }
                                                                            }
                                                                        }
                                                                    }
                                                                }
                                                                .frame(maxWidth: .infinity)
                                                                .padding(.leading, 15)
                                                            }
                                                            
                                                            Button {
                                                                isShowingSelectWishesToGiveSheet.toggle()
                                                            } label: {
                                                                Text("Select wish(es) to give")
                                                                    .style(textStyle: .text(.medium), color: .cForeground)
                                                                    .underline()
                                                                    .padding(.horizontal, 15)
                                                            }
                                                        }
                                                    }
                                                    .padding([.top], 35)
                                                    .padding(.bottom, 15)
                                                    .background { Color.cYellow }
                                                    .sheet(isPresented: $isShowingSelectWishesToGiveSheet) {
                                                        Task {
                                                            await vm.getEvent(documentId: documentId, isLoading: $vm.eventIsLoading)
                                                        }
                                                    } content: {
                                                        SelectWishesToGiveView(eventDocumentId: documentId, receiverUserId: giftie.user?.id ?? 0)
                                                    }
                                                    
                                                }
                                                
                                                VStack {
                                                    HStack {
                                                        HStack(spacing: 5) {
                                                            Avatar(
                                                                image: giftie.user?.avatar,
                                                                width: 22
                                                            )
                                                            .padding(4)
                                                            
                                                            Text("\(giftie.user?.firstname ?? "") \(giftie.user?.lastname ?? "")")
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
                            
                        } else {
                            
                            VStack(spacing: 20) {
                                Text("Did everyone join?")
                                    .style(textStyle: .title(.h2), color: .cForeground)
                                
                                Text("To get an giftee assigned, all members need to be registered and have accepted the invitation to join.")
                                    .style(textStyle: .text(.medium), color: .cForeground)
                                
                                // Assign button for event owner
                                if let ownerParticpant = vm.event?.eventParticipants?.first(where: { $0.role == .owner }), ownerParticpant.user?.id == vm.user?.id {
                                 
                                    Button("Randomize the giftees") {
                                        guard (vm.event?.eventParticipants?.count ?? 0) >= 2 else {
                                            alertManager.present(Alert(
                                                title: "Not enough accepted participants",
                                                message: "To randomize the giftees, at least two participants are required.",
                                                actions: {
                                                    Button("Manage invites") {
                                                        isShowingInvitesSheet.toggle()
                                                    }
                                                    
                                                    Button("OK", role: .cancel) { }
                                                }
                                            ))
                                            return
                                        }
                                        
                                        alertManager.present(Alert(
                                            title: "Randomize the giftees",
                                            message: "Are you sure that you would like to randomize the giftees? You can't add more people after this action.",
                                            actions: {
                                                Button("Assign giftees", role: .destructive) {
                                                    Task {
                                                        await vm.randomizeGifties(eventDocumentId: documentId, isLoading: $vm.eventIsLoading)
                                                        await vm.getEvent(documentId: documentId, isLoading: $vm.eventIsLoading)
                                                    }
                                                }
                                                
                                                Button("Cancel", role: .cancel) { }
                                            }
                                        ))
                                    }
                                    .style(textStyle: .text(.regular), color: .cOrange)
                                    
                                } else {
                                    
                                    Text("Ask the organizer to randomize the giftees.")
                                        .style(textStyle: .text(.regular), color: .cForeground)
                                    
                                }
                            }
                            .multilineTextAlignment(.center)
                            .padding(15)
                            
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
                        
                        if let ownerParticpant = vm.event?.eventParticipants?.first(where: { $0.role == .owner }), ownerParticpant.user?.id == vm.user?.id {
                            
                            Divider()
                            
                            Button("Manage invites", systemImage: "person.crop.circle.badge.plus") {
                                if (vm.event?.eventType == .oneToOne && (vm.event?.eventAssignments?.count ?? 0) > 0) {
                                    alertManager.present(Alert(
                                        title: "Not available",
                                        message: "This can't be managed anymore because the giftees have been randomized and assigned."
                                    ))
                                } else {
                                    isShowingInvitesSheet.toggle()
                                }
                            }
                            
                            Divider()
                            
                            NavigationLink {
                                EditEventView(documentId: documentId)
                            } label: {
                                Label("Edit event", systemImage: "pencil")
                            }
                            
                            Button("Delete event", systemImage: "trash", role: .destructive) {
                                alertManager.present(Alert(
                                    title: "Delete event",
                                    message: "Are you sure that you would like to delete the event?",
                                    actions: {
                                        Button("Delete", role: .destructive) {
                                            Task {
                                                do {
                                                    try await vm.deleteEvent(documentId: documentId, isLoading: $vm.eventIsLoading)
                                                    mode.wrappedValue.dismiss()
                                                } catch {
                                                    alertManager.present(Alert(
                                                        title: "Something went wrong!",
                                                        message: error.localizedDescription
                                                    ))
                                                    print(error)
                                                }
                                            }
                                        }
                                        
                                        Button("Cancel", role: .cancel) {
                                            print("Cancel")
                                        }
                                    }
                                ))
                            }
                        }
                        
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                    .disabled(vm.event == nil)
                }
                .sheet(isPresented: $isShowingInvitesSheet) {
                    InvitePeopleToEventView(eventDocumentId: documentId)
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
                EventView(documentId: "pru0pq1a39fci8ygjv36c50y")
                    .environmentObject(AlertManager())
                    .environmentObject(NavigationManager())
            }
    }
}
