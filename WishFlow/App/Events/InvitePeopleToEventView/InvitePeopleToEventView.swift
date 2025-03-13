//
//  InvitePeopleToEventView.swift
//  WishFlow
//
//  Created by Mees Akveld on 11/03/2025.
//

import SwiftUI

struct InvitePeopleToEventView: View {
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    @StateObject var vm: InvitePeopleToEventViewModel = InvitePeopleToEventViewModel()
    
    let eventDocumentId: String
    @State var email: String = ""
    
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
            
            // MARK: - Page
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

                    ScrollView {
                        LazyVStack(spacing: 40) {
                            FormWrapper { inputsErrors, isShowingInputsErrors in
                                Group {
                                    TextEntry(
                                        identifier: "email",
                                        value: $email,
                                        title: "Email",
                                        placeholder: "Enter the user's email",
                                        errors: inputsErrors,
                                        isShowingErrors: isShowingInputsErrors
                                    )
                                    .padding(.horizontal, 1)
                                }
                            } submit: { setIsLoading, setFormError, setFormSuccess, inputsErrors, isShowingInputsErrors in
                                Button {
                                    Task {
                                        setIsLoading(.isLoading)
                                        setFormError(nil)
                                        isShowingInputsErrors.wrappedValue = true
                                        
                                        if inputsErrors.isEmpty {
                                            do {
                                                let result = try await vm.addEventInvite(email: email, eventDocumentId: eventDocumentId)
                                                vm.eventInvites.append(result)
                                                email = ""
                                                
                                                isShowingInputsErrors.wrappedValue = false
                                            } catch {
                                                print(error)
                                                setFormError(error.localizedDescription)
                                            }
                                        }
                                        setIsLoading(.finished)
                                    }
                                } label: {
                                    DropEffect {
                                        HStack {
                                            Text("Invite")
                                                .style(textStyle: .text(.medium), color: .cBlack)
                                                .padding(15)
                                        }
                                        .frame(maxWidth: .infinity, maxHeight: 50)
                                        .background(Color.cGreen)
                                    }
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Invited")
                                    .style(textStyle: .text(.bold), color: .cForeground)
                                
                                VStack(spacing: 12) {
                                    ForEach(vm.eventInvites.filter({ $0.eventInviteStatus == .pending }), id: \.documentId) { invite in
                                        HStack(spacing: 15) {
                                            Avatar(image: nil, width: 30)
                                                .padding(.leading, 1)
                                            
                                            Text(invite.invitedUserEmail)
                                            
                                            Spacer()
                                            
                                            Button {
                                                Task {
                                                    await vm.deleteEventInvite(inviteDocumentId: invite.documentId)
                                                    vm.eventInvites = vm.eventInvites.filter({ $0.documentId != invite.documentId })
                                                }
                                            } label: {
                                                Image(systemName: "xmark")
                                            }
                                        }
                                        .loadingEffect(vm.eventInvitesIsLoading[invite.documentId]?.isInLoadingState() ?? false)
                                    }
                                    .style(textStyle: .text(.regular), color: .cForeground)
                                }
                                
                                if vm.eventInvites.filter({ $0.eventInviteStatus == .pending }).isEmpty {
                                    Text("There are no open invites.")
                                        .style(textStyle: .textSmall(.regular), color: .cForeground)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }
                            
                            if !vm.eventInvites.filter({ $0.eventInviteStatus == .denied }).isEmpty {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Denied")
                                        .style(textStyle: .text(.bold), color: .cForeground)
                                    
                                    VStack(spacing: 12) {
                                        ForEach(vm.eventInvites.filter({ $0.eventInviteStatus == .denied }), id: \.documentId) { invite in
                                            HStack(spacing: 15) {
                                                Avatar(image: nil, width: 30)
                                                    .padding(.leading, 1)
                                                
                                                Text(invite.invitedUserEmail)
                                                
                                                Spacer()
                                                
                                                Button {
                                                    Task {
                                                        await vm.deleteEventInvite(inviteDocumentId: invite.documentId)
                                                        vm.eventInvites = vm.eventInvites.filter({ $0.documentId != invite.documentId })
                                                    }
                                                } label: {
                                                    Image(systemName: "trash")
                                                }
                                            }
                                            .loadingEffect(vm.eventInvitesIsLoading[invite.documentId]?.isInLoadingState() ?? false)
                                        }
                                        .style(textStyle: .text(.regular), color: .cForeground)
                                    }
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Accepted")
                                    .style(textStyle: .text(.bold), color: .cForeground)
                                
                                VStack(spacing: 12) {
                                    ForEach(vm.participants, id: \.documentId) { participant in
                                        HStack(spacing: 15) {
                                            Avatar(image: participant.user?.avatar, width: 30)
                                                .padding(.leading, 1)
                                            
                                            Text("\(participant.user?.firstname ?? "") \(participant.user?.lastname ?? "")")
                                            
                                            Spacer()
                                        }
                                    }
                                    .style(textStyle: .text(.regular), color: .cForeground)
                                }
                                
                                if vm.participants.isEmpty {
                                    Text("Nobody has accepted yet.")
                                        .style(textStyle: .textSmall(.regular), color: .cForeground)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }
                        }
                    }
                }
                .loadingEffect(vm.eventIsLoading.isInLoadingState())
                .padding([.top, .horizontal])
            }
        }
        .task {
            await vm.initEvent(documentId: eventDocumentId, isLoading: $vm.eventIsLoading)
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
                        InvitePeopleToEventView(eventDocumentId: "yyi02rmev5oqpgxllz903avf")
                    }
            }
    }
}
