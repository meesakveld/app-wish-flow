//
//  SelectWishesToGiveView.swift
//  WishFlow
//
//  Created by Mees Akveld on 12/03/2025.
//

import SwiftUI

struct SelectWishesToGiveView: View {
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    @StateObject var vm: SelectWishesToGiveViewModel = SelectWishesToGiveViewModel()
    @EnvironmentObject var alertManager: AlertManager
    
    let eventDocumentId: String
    let receiverUserId: Int
    
    let columns = [
        GridItem(.flexible(), spacing: 15),
        GridItem(.flexible(), spacing: 15)
    ]
    
    @State var isShowingNotAvailableAlert: Bool = false
    
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
                            text: "Whoops! We can't find the event you are looking to assign wishes — try again later!"
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
            
            // MARK: - Event
            if !vm.eventHasError {
                VStack(spacing: 40) {
                    // MARK: - Title
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("\(vm.event?.title ?? "Event title") | \((vm.event?.eventDate ?? Date()).dateToStringFormatter(DateFormat: .dd_MMM_yyyy))")
                                .style(textStyle: .title(.h2), color: .cForeground)
                            
                            Text("Select the wish(es) you will give.")
                                .style(textStyle: .textSmall(.regular), color: .cForeground)
                            
                            if let minBudget = vm.event?.minBudget {
                                Text("**Min price**: \(minBudget.formatted())")
                                    .style(textStyle: .textSmall(.regular), color: .cForeground)
                            }
                            
                            if let maxBudget = vm.event?.maxBudget {
                                Text("**Max price**: \(maxBudget.formatted())")
                                    .style(textStyle: .textSmall(.regular), color: .cForeground)
                            }
                        }
                        Spacer()
                    }
                    .padding(.top, 10)
                    
                    ScrollView {
                        LazyVStack(spacing: 13) {
                            //MARK: Loading placeholders
                            if vm.wishesIsLoading.isInLoadingState() {
                                LazyVGrid(columns: columns, spacing: 15) {
                                    ForEach(0...4, id: \.self) { _ in
                                        HStack(alignment: .center, spacing: 20) {
                                            WishCard(wish: Gift())
                                            
                                            CheckCircle(isChecked: false) {}
                                        }
                                        .loadingEffect(true)
                                    }
                                }
                            }
                            
                            if (vm.wishes.isEmpty ? !vm.wishesIsLoading.isInLoadingState() : !vm.wishesIsLoading.isInLoadingState()) && !vm.wishesHasError {
                                //MARK: Wishes array
                                LazyVGrid(columns: columns, spacing: 15) {
                                    ForEach(vm.wishes, id: \.documentId) { wish in
                                        HStack(alignment: .center, spacing: 20) {
                                            let isChecked = vm.selectedGiftsIds.contains(where: { $0 == wish.documentId })
                                            let isCheckedWhenArrived = vm.selectedGiftsIdsOriginal.contains(where: { $0 == wish.documentId })
                                            let isAvailable: Bool = (wish.giftClaims?.count ?? 0) < wish.giftLimit
                                            
                                            WishCard(wish: wish)
                                                .opacity(isChecked ? 1 : 0.7)
                                            
                                            if isAvailable || isCheckedWhenArrived {
                                                CheckCircle(isChecked: isChecked) {
                                                    if !isChecked {
                                                        vm.selectedGiftsIds.append(wish.documentId)
                                                    } else {
                                                        vm.selectedGiftsIds = vm.selectedGiftsIds.filter { $0 != wish.documentId }
                                                    }
                                                }
                                            } else {
                                                Button {
                                                    isShowingNotAvailableAlert.toggle()
                                                } label: {
                                                    Image(systemName: "lock")
                                                        .frame(width: 25, height: 25)
                                                }
                                            }
                                        }
                                    }
                                }
                                
                                //MARK: No wishes
                                if vm.wishes.isEmpty {
                                    FeedbackMessage(
                                        image: "giftWithStars",
                                        text: "Whoops! No wishes found."
                                    ) { }
                                }
                                
                            }
                            
                            //MARK: Error handler
                            if vm.wishesHasError {
                                FeedbackMessage(
                                    image: "error",
                                    text: "Whoops! That didn’t work—try again later!"
                                ) {
                                    Button {
                                        Task {
                                            await vm.initWishes(eventDocumentId: eventDocumentId, receiverUserId: receiverUserId, isLoading: $vm.wishesIsLoading)
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
                            await vm.updateEventGiftClaims(eventDocumentId: eventDocumentId, selectedGiftsIds: vm.selectedGiftsIds, wishes: vm.wishes, isLoading: $vm.eventIsLoading)
                            if !vm.eventHasError {
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
                    .loadingEffect(vm.wishesIsLoading.isInLoadingState())
                    
                }
                .loadingEffect(vm.eventIsLoading.isInLoadingState())
                .task {
                    await vm.initEvent(documentId: eventDocumentId, isLoading: $vm.eventIsLoading)
                    await vm.initWishes(eventDocumentId: eventDocumentId, receiverUserId: receiverUserId, isLoading: $vm.wishesIsLoading)
                }
                .padding([.top, .horizontal])
                .alert("Not available – someone else has already selected this wish to buy.", isPresented: $isShowingNotAvailableAlert) {}
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
                        SelectWishesToGiveView(eventDocumentId: "yyi02rmev5oqpgxllz903avf", receiverUserId: 21)
                    }
            }
    }
}
