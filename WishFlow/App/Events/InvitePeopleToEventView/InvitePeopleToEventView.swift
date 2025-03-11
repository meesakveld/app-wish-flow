//
//  InvitePeopleToEventView.swift
//  WishFlow
//
//  Created by Mees Akveld on 11/03/2025.
//

import SwiftUI

@MainActor
class InvitePeopleToEventViewModel: ObservableObject {
    let user: User? = AuthenticationManager.shared.user
    
    @Published var event: Event? = nil
    @Published var eventIsLoading: LoadingState = .preparingToLoad
    @Published var eventHasError: Bool = false
    
    @Published var selectedEventsIds: [String] = []
    
    func initEvent(documentId: String, isLoading: Binding<LoadingState>) async {
        eventHasError = false
        setLoading(value: isLoading, .isLoading)
        do {
            // Get wish
//            let strapiResponse = try await GiftManager.shared.getGiftByDocumentId(documentId: documentId, userId: user?.id ?? 1)
//            event = strapiResponse
            
            // Add selectEventsId
//            if let events = event?.events {
//                selectedEventsIds = []
//                for event in events {
//                    selectedEventsIds.append(event.documentId)
//                }
//            }
        } catch {
            eventHasError = true
            print(error)
        }
        setLoading(value: isLoading, .finished)
    }
    
}

struct InvitePeopleToEventView: View {
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    @StateObject var vm: InvitePeopleToEventViewModel = InvitePeopleToEventViewModel()
    
    let eventDocumentId: String
    
    var body: some View {
        VStack {
            
            // MARK: - Error handling for when event is not found
            if vm.eventHasError {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        FeedbackMessage(
                            image: "error",
                            text: "Whoops! We can't find the event you are looking for to invite people — try again later!"
                        ) {
                            Button {
                                Task {
                                    await vm.initEvent(documentId: eventDocumentId, isLoading: $vm.eventIsLoading)
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
            if !vm.eventHasError {
                VStack(spacing: 40) {
                    // MARK: - Title
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("\(vm.event?.title ?? "Event title") | \((vm.event?.eventDate ?? Date()).dateToStringFormatter(DateFormat: .dd_MMM_yyyy))")
                                .style(textStyle: .title(.h2), color: .cForeground)
                            
                            Text("Invite people to this event.")
                                .style(textStyle: .textSmall(.regular), color: .cForeground)
                        }
                        Spacer()
                    }
                    .padding(.top, 10)

                }
                .loadingEffect(vm.eventIsLoading.isInLoadingState())
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
                EventView(documentId: "yyi02rmev5oqpgxllz903avf")
                    .environmentObject(AlertManager())
                    .sheet(isPresented: .constant(true)) {
                        InvitePeopleToEventView(eventDocumentId: "xju6n62zz117tcsvqskkj430")
                    }
            }
    }
}
