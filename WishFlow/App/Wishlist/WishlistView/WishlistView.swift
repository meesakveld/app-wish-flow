//
//  WishlistView.swift
//  WishFlow
//
//  Created by Mees Akveld on 04/03/2025.
//

import SwiftUI

struct WishlistView: View {
    @ObservedObject var vm: WishlistViewModel = WishlistViewModel()
    let user: User? = AuthenticationManager.shared.user
    
    let columns = [
        GridItem(.flexible(), spacing: 15),
        GridItem(.flexible(), spacing: 15)
    ]
    
    var body: some View {
        ScrollView {
            
            VStack(spacing: 40) {
                
                // MARK: - Header
                HStack(alignment: .center) {
                    Text("Wishlist")
                        .style(textStyle: .title(.h1), color: .cForeground)
                }
                .padding(.horizontal)
                
                // MARK: - Search
                VStack(alignment: .leading, spacing: 10) {
                    Searchbar(search: $vm.search, searchString: "Search an wish")
                        .onChange(of: vm.search, { _, _ in
                            Task {
                                await vm.getWishes(isLoading: $vm.wishesIsLoading)
                            }
                        })
                        .padding(.horizontal)
                    
                    // MARK: Sort & filter
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            SortLabel(icon: "calendar", state: vm.sortWishesDate, filterOn: "Filter on addition date") {
                                vm.sortWishesDate.toggle()
                            }
                            .disabled(vm.wishesIsLoading.isInLoadingState())
                            .opacity(vm.activeSort == .date ? 1 : 0.7)
                            .onChange(of: vm.sortWishesDate) { _, _ in
                                Task { await vm.getWishes(isLoading: $vm.wishesIsLoading) }
                            }
                            
                            SortLabel(icon: "eurosign", state: vm.sortWishesPrice, filterOn: "Filter on price") {
                                vm.sortWishesPrice.toggle()
                            }
                            .disabled(vm.wishesIsLoading.isInLoadingState())
                            .opacity(vm.activeSort == .price ? 1 : 0.7)
                            .onChange(of: vm.sortWishesPrice) { _, _ in
                                Task { await vm.getWishes(isLoading: $vm.wishesIsLoading) }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .fixedSize(horizontal: false, vertical: true)
                }
                
                
                // MARK: - Wishes
                LazyVStack(spacing: 13) {
                    //MARK: Loading placeholders
                    if vm.wishesIsLoading.isLoading() {
                        LazyVGrid(columns: columns, spacing: 15) {
                            ForEach(0...4, id: \.self) { _ in
                                WishCard(wish: Gift())
                                    .loadingEffect(true)
                            }
                        }
                    }
                    
                    if (vm.wishes.isEmpty ? !vm.wishesIsLoading.isInLoadingState() : !vm.wishesIsLoading.isLoading()) && !vm.wishesHasError {
                        //MARK: Wishes array
                        LazyVGrid(columns: columns, spacing: 15) {
                            ForEach(vm.wishes, id: \.documentId) { wish in
                                NavigationLink {
                                    // EventView(documentId: event.documentId)
                                } label: {
                                    WishCard(wish: wish)
                                }
                            }
                        }
                        
                        
                        //MARK: No wishes
                        if vm.wishes.isEmpty && vm.search.isEmpty {
                            FeedbackMessage(
                                image: "giftWithStars",
                                text: "No wishes yet — why not add something exciting?"
                            ) {
                                NavigationLink {
                                    EventsView()
                                } label: {
                                    HStack {
                                        Image(systemName: "plus.circle")
                                        
                                        Text("Add new wish")
                                    }
                                    .style(textStyle: .text(.regular), color: .cOrange)
                                }
                            }
                        }
                        
                        //MARK: No wishes found after filter
                        if vm.wishes.isEmpty && !vm.search.isEmpty {
                            FeedbackMessage(
                                image: "search",
                                text: "Whoops! No events found!"
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
                                    await vm.getWishes(isLoading: $vm.wishesIsLoading)
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
                await vm.getWishes(isLoading: $vm.wishesIsLoading)
            }
        }
        .task {
            await vm.getWishes(isLoading: $vm.wishesIsLoading)
        }
        .toolbar {
            Button {
                print("add event")
            } label: {
                Image(systemName: "plus.circle")
            }
        }
        .background(Color.cBackground.ignoresSafeArea())
        
    }
}

#Preview {
    NavigationStack {
        NavigationLink("", value: true)
            .navigationDestination(isPresented: .constant(true)) {
                WishlistView()
            }
    }
}

