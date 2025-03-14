//
//  HomeView.swift
//  WishFlow
//
//  Created by Mees Akveld on 20/02/2025.
//

import SwiftUI

struct HomeView: View {
    @StateObject var vm: HomeViewModel = HomeViewModel()
    @EnvironmentObject private var navigationManager: NavigationManager
    let user: User? = AuthenticationManager.shared.user
    
    @State var isShowingUpdateProfileSheet: Bool = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 40) {
                
                // MARK: - Header
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(greet())
                            .style(textStyle: .text(.regular), color: .cForeground)
                        HStack(alignment: .center) {
                            if let firstname = user?.firstname {
                                Text(firstname)
                                    .style(textStyle: .title(.h1), color: .cForeground)
                            }
                            
                            Image("smiley")
                                .frame(maxWidth: 27, maxHeight: 27)
                        }
                    }
                    
                    Spacer()
                    
                    HStack {
                        //TODO: MAKE BUTTON TO SHOW NOTIFICATIONS
                        //TODO: ONAPPEAR -> CHECK FOR NOTIFICATIONS
                        Image(systemName: "bell.circle")
                            .font(.custom("", fixedSize: 32))
                            .foregroundStyle(.cForeground)
                    }
                    
                    Menu {
                        Button("Update profile", systemImage: "pencil") {
                            isShowingUpdateProfileSheet.toggle()
                        }
                        
                        Divider()
                        
                        Button("Logout", systemImage: "rectangle.portrait.and.arrow.right", role: .destructive) {
                            AuthenticationManager.shared.logout()
                            navigationManager.navigate(to: .welcome)
                        }
                    } label: {
                        Avatar(image: user?.avatar)
                        .padding(1)
                    }
                }
                .sheet(isPresented: $isShowingUpdateProfileSheet) {
                    //
                } content: {
                    EditProfileView()
                }

                
                // MARK: - Search
                NavigationLink {
                    EventsView(searchActivated: true)
                } label: {
                    Searchbar(search: .constant(""), searchString: "Search an event")
                        .disabled(true)
                }
                
                
                // MARK: - Wistlist & Buylist
                HStack {
                    NavigationLink {
                        WishlistView()
                    } label: {
                        Card(title: "Wish\nlist", image: "giftWithStars", bgColor: .cBlue)
                    }
                    
                    Card(title: "Buy\nlist", image: "giftlist", bgColor: .cOrange)
                }
                
                
                // MARK: - Upcoming events
                VStack {
                    HStack {
                        Text("Upcoming Events")
                            .style(textStyle: .text(.bold), color: .cForeground)
                        
                        Spacer()
                        
                        NavigationLink {
                            EventsView()
                        } label: {
                            HStack {
                                Text("See all")
                                Image(systemName: "arrow.up.right")
                            }
                        }
                        .style(textStyle: .textSmall(.regular), color: .cForeground)
                    }
                    
                    
                    VStack(spacing: 13) {
                        //MARK: Loading placeholders
                        if vm.upcomingEventsIsLoading.isLoading() {
                            ForEach(0...2, id: \.self) { _ in
                                EventCard(event: Event())
                                    .loadingEffect(true)
                            }
                        }
                        
                        if !vm.upcomingEventsIsLoading.isInLoadingState() && !vm.upcomingEventsHasError {
                            //MARK: Upcoming events array
                            ForEach(vm.upcomingEvents, id: \.documentId) { event in
                                NavigationLink {
                                    EventView(documentId: event.documentId)
                                } label: {
                                    EventCard(event: event)
                                }
                            }
                            
                            //MARK: No upcoming events
                            if vm.upcomingEvents.isEmpty {
                                FeedbackMessage(
                                    image: "event",
                                    text: "No upcoming events planned — why not plan something fun?"
                                ) {
                                    NavigationLink {
                                        AddEventView()
                                    } label: {
                                        HStack {
                                            Image(systemName: "plus.circle")
                                            
                                            Text("Add new event")
                                        }
                                        .style(textStyle: .text(.regular), color: .cOrange)
                                    }
                                }
                            }
                        }
                        
                        //MARK: Error message
                        if vm.upcomingEventsHasError {
                            FeedbackMessage(
                                image: "error",
                                text: "Whoops! That didn’t work—try again later!"
                            ) {
                                Button {
                                    Task {
                                        await vm.getUpcomingEvents(isLoading: $vm.upcomingEventsIsLoading)
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
                .onAppear {
                    Task {
                        await vm.getUpcomingEvents(isLoading: $vm.upcomingEventsIsLoading)
                    }
                }
                
            }
            .padding(.horizontal)
        }
        .refreshable {
            Task {
                await vm.getUpcomingEvents(isLoading: $vm.upcomingEventsIsLoading)
            }
        }
        .background(Color.cBackground.ignoresSafeArea())
    }
}

#Preview {
    NavigationStack {
        HomeView()
            .environmentObject(NavigationManager())
    }
}
