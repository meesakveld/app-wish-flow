//
//  BuylistView.swift
//  WishFlow
//
//  Created by Mees Akveld on 14/03/2025.
//

import SwiftUI
import StrapiSwift

@MainActor
class BuylistViewModel: ObservableObject {
    let user: User? = AuthenticationManager.shared.user
    
    @Published var giftClaimsPerEvent: [GiftClaimsPerEvent] = []
    @Published var giftClaimsPerEventIsLoading: LoadingState = .preparingToLoad
    @Published var giftClaimsPerEventHasError: Bool = false
    
    @Published var giftClaimIsLoading: [String: Bool] = [:]
    
    struct GiftClaimsPerEvent {
        let id: String = UUID().uuidString
        let event: Event
        var giftClaims: [GiftClaim]
        
        init(event: Event, giftClaims: [GiftClaim]) {
            self.event = event
            self.giftClaims = giftClaims
        }
        
        init() {
            self.event = Event()
            self.giftClaims = [GiftClaim(), GiftClaim(), GiftClaim() ]
        }
    }
    
    // MARK: - FUNCTIONS
    
    func getGiftClaimsPerEvent(isLoading: Binding<LoadingState>) async {
        giftClaimsPerEventHasError = false
        setLoading(value: isLoading, .isLoading)
        do {
            let currentDate = Date().dateToStringFormatter(DateFormat: .yyyy_MM_dd)
            
            let response = try await Strapi.contentManager.collection("gift-claims")
                .populate("gift") { gift in
                    gift.populate("image")
                }
                .populate("event") { event in
                    event.populate("image")
                }
                .filter("[user][id]", operator: .equal, value: user?.id ?? 0)
                .filter("[event][eventDate]", operator: .greaterThanOrEqual, value: currentDate)
                .getDocuments(as: [GiftClaim].self)
                .data
            
            var groupedClaims: [GiftClaimsPerEvent] = []
            
            // Group GiftClaims by Event manually
            for claim in response {
                if let event = claim.event {
                    if let index = groupedClaims.firstIndex(where: { $0.event.id == event.id }) {
                        // Event already in the array, append GiftClaim
                        groupedClaims[index].giftClaims.append(claim)
                    } else {
                        // New Event, create new grouping
                        let newGroup = GiftClaimsPerEvent(event: event, giftClaims: [claim])
                        groupedClaims.append(newGroup)
                    }
                }
            }
            
            giftClaimsPerEvent = groupedClaims
        } catch {
            giftClaimsPerEventHasError = true
            print(error)
        }
        setLoading(value: isLoading, .finished)
    }
    
    func updateGiftClaimStatus(giftClaimDocumentId: String, newStatus: GiftStatus) async {
        giftClaimIsLoading[giftClaimDocumentId] = true
        do {
            try await Strapi.contentManager.collection("gift-claims")
                .withDocumentId(giftClaimDocumentId)
                .putData(StrapiRequestBody([
                    "giftStatus": .string(newStatus.rawValue)
                ]), as: GiftClaim.self)
            
            if let eventIndex = giftClaimsPerEvent.firstIndex(where: { $0.giftClaims.contains(where: { $0.documentId == giftClaimDocumentId }) }) {
                if let claimIndex = giftClaimsPerEvent[eventIndex].giftClaims.firstIndex(where: { $0.documentId == giftClaimDocumentId }) {
                    giftClaimsPerEvent[eventIndex].giftClaims[claimIndex].giftStatus = newStatus
                }
            }
        } catch {
            print(error)
        }
        giftClaimIsLoading[giftClaimDocumentId] = false
    }
    
    func deleteGiftClaim(giftClaimDocumentId: String) async {
        giftClaimIsLoading[giftClaimDocumentId] = true
        do {
            try await Strapi.contentManager.collection("gift-claims").withDocumentId(giftClaimDocumentId).delete()
            
            giftClaimsPerEvent = giftClaimsPerEvent.compactMap { eventGroup -> GiftClaimsPerEvent? in
                let updatedClaims = eventGroup.giftClaims.filter { $0.documentId != giftClaimDocumentId }
                return updatedClaims.isEmpty ? nil : GiftClaimsPerEvent(event: eventGroup.event, giftClaims: updatedClaims)
            }
            
        } catch {
            print(error)
        }
        giftClaimIsLoading[giftClaimDocumentId] = false
    }
}

struct BuylistView: View {
    @StateObject var vm: BuylistViewModel = BuylistViewModel()
    
    let columns = [
        GridItem(.flexible(), spacing: 15),
        GridItem(.flexible(), spacing: 15)
    ]
    
    var body: some View {
        ScrollView {
            
            VStack(spacing: 40) {
                
                // MARK: - Header
                HStack(alignment: .center) {
                    Text("Buylist")
                        .style(textStyle: .title(.h1), color: .cForeground)
                }
                .padding(.horizontal)
                
                // MARK: - Wishes
                LazyVStack(spacing: 13) {
                    //MARK: Loading placeholders
                    if vm.giftClaimsPerEventIsLoading.isInLoadingState() {
                        VStack(spacing: 50) {
                            ForEach(0...1, id: \.self) { _ in
                                ZStack {
                                    DropEffect {
                                        ScrollView(.horizontal, showsIndicators: false) {
                                            LazyHStack(spacing: 15) {
                                                ForEach(BuylistViewModel.GiftClaimsPerEvent().giftClaims, id: \.documentId) { claim in
                                                    if let gift = claim.gift {
                                                        VStack {
                                                            NavigationLink {
                                                                WishView(documentId: gift.documentId)
                                                            } label: {
                                                                WishCard(wish: gift)
                                                                    .frame(height: 200)
                                                            }
                                                            
                                                            DropEffect {
                                                                HStack {
                                                                    Text(claim.giftStatus.title)
                                                                        .style(textStyle: .text(.medium), color: .cBlack)
                                                                    
                                                                    Spacer()
                                                                    
                                                                    Image(systemName: "chevron.down")
                                                                }
                                                                .padding(.vertical, 10)
                                                                .padding(.horizontal, 15)
                                                                .background(Color.cGreen)
                                                            }
                                                        }
                                                        .frame(width: 150)
                                                    }
                                                }
                                            }
                                            .frame(maxWidth: .infinity)
                                            .padding(.leading, 15)
                                        }
                                        .padding([.top], 35)
                                        .padding(.bottom, 15)
                                        .background { Color.cYellow }
                                    }
                                    
                                    VStack {
                                        HStack {
                                            HStack(spacing: 5) {
                                                ZStack {
                                                    Circle()
                                                        .frame(width: 22, height: 22)
                                                        .foregroundStyle(.cGreen)
                                                }
                                                .overlay(Circle().stroke(Color.cForeground, lineWidth: 2))
                                                .padding(4)
                                                
                                                Text("Event title")
                                                    .style(textStyle: .textSmall(.regular), color: .cBlack)
                                                    .lineLimit(1)
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
                                .loadingEffect(true)
                            }
                        }
                    }
                    
                    if (vm.giftClaimsPerEvent.isEmpty ? !vm.giftClaimsPerEventIsLoading.isInLoadingState() : !vm.giftClaimsPerEventIsLoading.isLoading()) && !vm.giftClaimsPerEventHasError {
                        //MARK: Array
                        VStack(spacing: 50) {
                            ForEach(vm.giftClaimsPerEvent, id: \.id) { giftClaimsPerEvent in
                                ZStack {
                                    DropEffect {
                                        ScrollView(.horizontal, showsIndicators: false) {
                                            LazyHStack(spacing: 15) {
                                                ForEach(giftClaimsPerEvent.giftClaims, id: \.documentId) { claim in
                                                    if let gift = claim.gift {
                                                        VStack {
                                                            NavigationLink {
                                                                WishView(documentId: gift.documentId)
                                                            } label: {
                                                                WishCard(wish: gift)
                                                                    .frame(height: 200)
                                                            }
                                                            
                                                            Menu {
                                                                Button("Reserved", systemImage: claim.giftStatus == .reserved ? "checkmark" : "") {
                                                                    Task { await vm.updateGiftClaimStatus(giftClaimDocumentId: claim.documentId, newStatus: .reserved) }
                                                                }
                                                                
                                                                Button("Purchased", systemImage: claim.giftStatus == .purchased ? "checkmark" : "") {
                                                                    Task { await vm.updateGiftClaimStatus(giftClaimDocumentId: claim.documentId, newStatus: .purchased) }
                                                                }
                                                                
                                                                Divider()
                                                                
                                                                Button("Remove claim", role: .destructive) {
                                                                    Task { await vm.deleteGiftClaim(giftClaimDocumentId: claim.documentId) }
                                                                }
                                                            } label: {
                                                                DropEffect {
                                                                    HStack {
                                                                        Text(claim.giftStatus.title)
                                                                            .style(textStyle: .text(.medium), color: .cBlack)
                                                                        
                                                                        Spacer()
                                                                        
                                                                        Image(systemName: "chevron.down")
                                                                    }
                                                                    .padding(.vertical, 10)
                                                                    .padding(.horizontal, 15)
                                                                    .background(Color.cGreen)
                                                                }
                                                            }
                                                        }
                                                        .loadingEffect(vm.giftClaimIsLoading[claim.documentId] ?? false)
                                                        .frame(width: 150)
                                                    }
                                                }
                                            }
                                            .frame(maxWidth: .infinity)
                                            .padding(.leading, 15)
                                        }
                                        .padding([.top], 35)
                                        .padding(.bottom, 15)
                                        .background { Color.cYellow }
                                    }
                                    
                                    VStack {
                                        HStack {
                                            NavigationLink {
                                                EventView(documentId: giftClaimsPerEvent.event.documentId)
                                            } label: {
                                                HStack(spacing: 5) {
                                                    ZStack {
                                                        Circle()
                                                            .frame(width: 22, height: 22)
                                                            .foregroundStyle(.cGreen)
                                                        
                                                        if let url = giftClaimsPerEvent.event.image?.getURL(size: .thumbnail)  {
                                                            AsyncImage(url: URL(string: url)) { image in
                                                                image.resizable()
                                                                    .scaledToFill()
                                                            } placeholder: {
                                                                ProgressView()
                                                            }
                                                            .frame(width: 22, height: 22)
                                                            .clipShape(Circle())
                                                        }
                                                    }
                                                    .overlay(Circle().stroke(Color.cForeground, lineWidth: 2))
                                                    .padding(4)
                                                    
                                                    Text(giftClaimsPerEvent.event.title)
                                                        .style(textStyle: .textSmall(.regular), color: .cBlack)
                                                        .lineLimit(1)
                                                        .padding(.trailing, 10)
                                                }
                                                .padding(1)
                                                .background(Color.cOrange)
                                                .cornerRadius(25)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 25)
                                                        .stroke(Color.cBlack, lineWidth: 1.5)
                                                )
                                                
                                            }
                                            
                                            Spacer()
                                        }
                                        Spacer()
                                    }
                                    .offset(x: 15, y: -10)
                                }
                            }
                        }
                        
                        
                        //MARK: No wishes
                        if vm.giftClaimsPerEvent.isEmpty {
                            FeedbackMessage(
                                image: "giftWithStars",
                                text: "No wishes selected yet."
                            ) { }
                        }
                    }
                    
                    //MARK: Error handler
                    if vm.giftClaimsPerEventHasError {
                        FeedbackMessage(
                            image: "error",
                            text: "Whoops! That didn’t work—try again later!"
                        ) {
                            Button {
                                Task {
                                    await vm.getGiftClaimsPerEvent(isLoading: $vm.giftClaimsPerEventIsLoading)
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
                .padding(.horizontal)
                .frame(maxHeight: .infinity)
                
            }
            
        }
        .refreshable {
            Task {
                await vm.getGiftClaimsPerEvent(isLoading: $vm.giftClaimsPerEventIsLoading)
            }
        }
        .task {
            await vm.getGiftClaimsPerEvent(isLoading: $vm.giftClaimsPerEventIsLoading)
        }
        .background(Color.cBackground.ignoresSafeArea())
    }
}

#Preview {
    NavigationStack {
        NavigationLink("", value: true)
            .navigationDestination(isPresented: .constant(true)) {
                BuylistView()
            }
    }
}
