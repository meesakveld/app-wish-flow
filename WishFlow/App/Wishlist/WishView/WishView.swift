//
//  WishView.swift
//  WishFlow
//
//  Created by Mees Akveld on 04/03/2025.
//

import SwiftUI

struct WishView: View {
    let documentId: String
    @ObservedObject var vm: WishViewModel = WishViewModel()
    
    @State var showAllParticipants: Bool = false
    @State var spacingParticipants: CGFloat = -15
    
    var body: some View {
        ScrollView {
            // MARK: - Error handling for when event is not found
            if vm.wishHasError {
                VStack {
                    Spacer()
                    
                    HStack {
                        Spacer()
                        FeedbackMessage(
                            image: "error",
                            text: "Whoops! We can't find the wish you are looking for — try again later!"
                        ) {
                            Button {
                                Task {
                                    await vm.getWish(documentId: documentId, isLoading: $vm.wishIsLoading)
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
            
            // MARK: - Wish
            if !vm.wishHasError {
                VStack(spacing: 30) {
                    
                    // MARK: - Title
                    HStack(alignment: .center) {
                        Text(vm.wish?.title ?? "Wish title")
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
                                
                                if let url = vm.wish?.image?.getURL(size: .small) {
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
                        
                    }
                    
                    // MARK: - Info
                    VStack(spacing: 30) {
                        // MARK: Description
                        HStack {
                            Text(
                                vm.wish?.description ?? "Lorem ipsum dolor sit amet consectetur. Eros fusce ut ipsum in velit eu eros. Consectetur id enim eleifend eget sit lacus."
                            )
                            .textSelection(.enabled)
                            
                            Spacer()
                        }
                        .style(textStyle: .text(.regular), color: .cForeground)
                        .multilineTextAlignment(.leading)
                        
                        // MARK: Details
                        VStack(alignment: .leading, spacing: 10) {
                            
                            // Price
                            HStack(alignment: .center) {
                                Text("Price:")
                                    .style(textStyle: .text(.medium), color: .cBlack)
                                
                                Text(vm.wish?.price?.formatted() ?? "€20")
                                    .style(textStyle: .text(.regular), color: .cBlack)
                                
                                Spacer()
                            }
                            
                            // URL
                            if let url = vm.wish?.url {
                                HStack(alignment: .center) {
                                    Text("URL:")
                                        .style(textStyle: .text(.medium), color: .cBlack)
                                    
                                    if let url = URL(string: url), let host = url.host() {
                                        Link(destination: url) {
                                            Text(host)
                                                .style(textStyle: .text(.regular), color: .cBlack)
                                                .underline()
                                        }
                                    }
                                    
                                    Spacer()
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                        
                        if (vm.wish?.giftLimit ?? 0) > 1 {
                            HStack {
                                Text("""
                                    \(vm.wish?.user?.firstname ?? "") would like to receive this gift **\(vm.wish?.giftLimit ?? 999) times**. Currently, **\(vm.wish?.giftClaims?.count ?? 0) \((vm.wish?.giftClaims?.count ?? 0) == 1 ? "person" : "people")** have stated they will buy it.
                                    """)
                                .style(textStyle: .text(.regular), color: .cForeground)
                                .multilineTextAlignment(.leading)
                                
                                Spacer()
                            }
                        }
                    }
                    
                    // MARK: - Asked for in events
                    if let wishUserId = vm.wish?.user?.id, let userId = vm.user?.id, wishUserId == userId {
                        VStack (spacing: 10) {
                            HStack {
                                Text("Asked for in events")
                                    .style(textStyle: .text(.bold), color: .cForeground)
                                Spacer()
                            }
                            
                            if let events = vm.wish?.events {
                                if events.count > 0 {
                                    ForEach(events, id: \.documentId) { event in
                                        EventCard(event: event)
                                    }
                                } else {
                                    HStack {
                                        Text("You haven't added this wish to any events.")
                                            .style(textStyle: .textSmall(.regular), color: .cForeground)
                                            .opacity(0.8)
                                        Spacer()
                                    }
                                }
                            }
                        }
                    }
                }
                .loadingEffect(vm.wishIsLoading.isInLoadingState())
                .padding(.horizontal)
                .task { await vm.getWish(documentId: documentId, isLoading: $vm.wishIsLoading) }
                .toolbar {
                    Menu {
                       
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                    .disabled(vm.wish == nil)
                }
            }
        }
        .refreshable {
            Task { await vm.getWish(documentId: documentId, isLoading: $vm.wishIsLoading) }
        }
        .background(Color.cBackground.ignoresSafeArea())
    }
}


#Preview {
    NavigationStack {
        NavigationLink("", value: true)
            .navigationDestination(isPresented: .constant(true)) {
                WishView(documentId: "j7u00k3sajkspg36gw0srngk")
            }
    }
}
