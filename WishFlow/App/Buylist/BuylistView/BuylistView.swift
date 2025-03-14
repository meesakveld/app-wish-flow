//
//  BuylistView.swift
//  WishFlow
//
//  Created by Mees Akveld on 14/03/2025.
//

import SwiftUI

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
