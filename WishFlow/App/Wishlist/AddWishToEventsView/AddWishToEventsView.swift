//
//  AddWishToEventsView.swift
//  WishFlow
//
//  Created by Mees Akveld on 10/03/2025.
//

import SwiftUI

@MainActor
class AddWishToEventsViewModel: ObservableObject {
    let user: User? = AuthenticationManager.shared.user
    
    @Published var wish: Gift? = nil
    @Published var wishIsLoading: LoadingState = .preparingToLoad
    @Published var wishHasError: Bool = false
    
    @Published var events: [Event] = []
    @Published var eventsIsLoading: LoadingState = .preparingToLoad
    @Published var eventsHasError: Bool = false
    
    @Published var selectedEventsIds: [String] = []
    
    func initWish(documentId: String, isLoading: Binding<LoadingState>) async {
        wishHasError = false
        setLoading(value: isLoading, .isLoading)
        do {
            // Get wish
            let strapiResponse = try await GiftManager.shared.getGiftByDocumentId(documentId: documentId, userId: user?.id ?? 1)
            wish = strapiResponse
            
            // Add selectEventsId
            if let events = wish?.events {
                selectedEventsIds = []
                for event in events {
                    selectedEventsIds.append(event.documentId)
                }
            }
        } catch {
            wishHasError = true
            print(error)
        }
        setLoading(value: isLoading, .finished)
    }
    
    func initEvents(isLoading: Binding<LoadingState>) async {
        eventsHasError = false
        setLoading(value: isLoading, .isLoading)
        do {
            // Get events
            let strapiResponse = try await EventManager.shared.getUpcomingEventsWithUserId(
                userId: user!.id,
                limit: -1
            )
            events = strapiResponse
        } catch {
            eventsHasError = true
            print(error)
        }
        setLoading(value: isLoading, .finished)
    }
    
    func updateGiftWishEventsAssignment(documentId: String, events: [String], isLoading: Binding<LoadingState>) async {
        setLoading(value: isLoading, .preparingToLoad)
        do {
            try await GiftManager.shared.updateGiftByDocumentId(documentId: documentId, events: events)
        } catch {
            wishHasError = true
            print(error)
        }
        setLoading(value: isLoading, .finished)
    }
}

struct AddWishToEventsView: View {
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    @StateObject var vm: AddWishToEventsViewModel = AddWishToEventsViewModel()
    
    let wishDocumentId: String
    
    var body: some View {
        VStack {
            
            // MARK: - Error handling for when wish is not found
            if vm.wishHasError {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        FeedbackMessage(
                            image: "error",
                            text: "Whoops! We can't find the wish you are looking to assign — try again later!"
                        ) {
                            Button {
                                Task {
                                    await vm.initWish(documentId: wishDocumentId, isLoading: $vm.wishIsLoading)
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
                .frame(maxWidth: .infinity ,maxHeight: .infinity)
            }
            
            // MARK: - Wish
            if !vm.wishHasError {
                VStack(spacing: 40) {
                    // MARK: - Title
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("\(vm.wish?.title ?? "Wish title") | \(vm.wish?.price?.formatted() ?? "€10")")
                                .style(textStyle: .title(.h2), color: .cForeground)
                            
                            Text("Select one or multiple events where you would like to receive your wish.")
                                .style(textStyle: .textSmall(.regular), color: .cForeground)
                        }
                        Spacer()
                    }
                    .padding(.top, 10)
                    
                    ScrollView {
                        LazyVStack(spacing: 13) {
                            //MARK: Loading placeholders
                            if vm.eventsIsLoading.isInLoadingState() {
                                ForEach(0...3, id: \.self) { _ in
                                    HStack(alignment: .center, spacing: 20) {
                                        EventCard(event: Event())
                                        
                                        CheckCircle(isChecked: false) {}
                                    }
                                    .loadingEffect(true)
                                }
                            }
                            
                            if (vm.events.isEmpty ? !vm.eventsIsLoading.isInLoadingState() : !vm.eventsIsLoading.isInLoadingState()) && !vm.eventsHasError {
                                //MARK: Events array
                                ForEach(vm.events, id: \.documentId) { event in
                                    HStack(alignment: .center, spacing: 20) {
                                        EventCard(event: event)
                                        
                                        let isChecked = vm.selectedEventsIds.contains(where: { $0 == event.documentId })
                                        CheckCircle(isChecked: isChecked) {
                                            if !isChecked {
                                                vm.selectedEventsIds.append(event.documentId)
                                            } else {
                                                vm.selectedEventsIds = vm.selectedEventsIds.filter { $0 != event.documentId }
                                            }
                                        }
                                    }
                                }
                                
                                //MARK: No events
                                if vm.events.isEmpty {
                                    FeedbackMessage(
                                        image: "event",
                                        text: "Whoops! No upcoming events found."
                                    ) { }
                                }
                                
                            }
                            
                            //MARK: Error handler
                            if vm.eventsHasError {
                                FeedbackMessage(
                                    image: "error",
                                    text: "Whoops! That didn’t work—try again later!"
                                ) {
                                    Button {
                                        Task {
                                            await vm.initEvents(isLoading: $vm.eventsIsLoading)
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
                    }
                    
                    Button {
                        Task {
                            await vm.updateGiftWishEventsAssignment(documentId: wishDocumentId, events: vm.selectedEventsIds, isLoading: $vm.eventsIsLoading)
                            if !vm.wishHasError {
                                mode.wrappedValue.dismiss()
                            }
                        }
                    } label: {
                        DropEffect {
                            HStack {
                                Text("Save")
                                    .style(textStyle: .text(.medium), color: .cBlack)
                                    .padding(15)
                            }
                            .frame(maxWidth: .infinity, maxHeight: 50)
                            .background(Color.cGreen)
                        }
                    }
                    .loadingEffect(vm.eventsIsLoading.isInLoadingState())

                }
                .loadingEffect(vm.wishIsLoading.isInLoadingState())
                .task {
                    await vm.initWish(documentId: wishDocumentId, isLoading: $vm.wishIsLoading)
                    await vm.initEvents(isLoading: $vm.eventsIsLoading)
                }
                .padding([.top, .horizontal])
            }
            
        }
        .background(Color.cBackground)
    }
}

#Preview {
    NavigationStack {
        NavigationLink("", value: true)
            .navigationDestination(isPresented: .constant(true)) {
                WishView(documentId: "xju6n62zz117tcsvqskkj430")
                    .environmentObject(NavigationManager())
                    .environmentObject(AlertManager())
                    .sheet(isPresented: .constant(true)) {
                        AddWishToEventsView(wishDocumentId: "xju6n62zz117tcsvqskkj430")
                    }
            }
    }
}
