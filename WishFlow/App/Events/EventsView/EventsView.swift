//
//  EventsView.swift
//  WishFlow
//
//  Created by Mees Akveld on 23/02/2025.
//

import SwiftUI

struct EventsView: View {
    @ObservedObject var vm: EventsViewModel = EventsViewModel()
    let user: User? = AuthenticationManager.shared.user
    var searchActivated: Bool = false
    
    init() { }
    
    init(searchActivated: Bool) {
        self.searchActivated = searchActivated
    }
    
    var body: some View {
        VStack(spacing: 40) {
            
            // MARK: - Header
            HStack(alignment: .center) {
                Text("Events")
                    .style(textStyle: .title(.h1), color: .cForeground)
            }
            .padding(.horizontal)
            
            // MARK: - Search
            VStack(alignment: .leading, spacing: 10) {
                Searchbar(search: $vm.search, searchString: "Search an event", autoFocus: searchActivated)
                    .onChange(of: vm.search, { _, _ in
                        Task {
                            await vm.getEvents(isLoading: $vm.eventsIsLoading)
                        }
                    })
                    .padding(.horizontal)
                
                // MARK: Sort & filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        SortLabel(icon: "calendar", state: vm.sortEventDate, filterOn: "Filter on event date") {
                            vm.sortEventDate.toggle()
                        }
                        .disabled(vm.eventsIsLoading.isInLoadingState())
                    }
                    .padding(.horizontal)
                }
                .fixedSize(horizontal: false, vertical: true)
                .onChange(of: vm.sortEventDate) { _, _ in
                    Task {
                        await vm.getEvents(isLoading: $vm.eventsIsLoading)
                    }
                }
            }
            
            
            // MARK: - Events
            ScrollView {
                
                LazyVStack(spacing: 13) {
                    //MARK: Loading placeholders
                    if vm.eventsIsLoading.isLoading() {
                        ForEach(0...2, id: \.self) { _ in
                            EventCard(event: Event())
                                .loadingEffect(true)
                        }
                    }
                    
                    if (vm.events.isEmpty ? !vm.eventsIsLoading.isInLoadingState() : !vm.eventsIsLoading.isLoading()) && !vm.eventsHasError {
                        //MARK: Events array
                        ForEach(vm.events, id: \.documentId) { event in
                            NavigationLink {
                                EventView(documentId: event.documentId)
                            } label: {
                                EventCard(event: event)
                            }
                        }
                        
                        //MARK: No events
                        if vm.events.isEmpty && vm.search.isEmpty {
                            FeedbackMessage(
                                image: "event",
                                text: "No events planned — why not plan something fun?"
                            ) {
                                NavigationLink {
                                    EventsView()
                                } label: {
                                    HStack {
                                        Image(systemName: "plus.circle")
                                        
                                        Text("Add new event")
                                    }
                                    .style(textStyle: .text(.regular), color: .cOrange)
                                }
                            }
                        }
                        
                        //MARK: No events found after filter
                        if vm.events.isEmpty && !vm.search.isEmpty {
                            FeedbackMessage(
                                image: "search",
                                text: "Whoops! No events found!"
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
                                    await vm.getEvents(isLoading: $vm.eventsIsLoading)
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
            .task {
                await vm.getEvents(isLoading: $vm.eventsIsLoading)
            }
            .padding(.horizontal)
            .frame(maxHeight: .infinity)
            
        }
        .toolbar {
            NavigationLink {
                AddEventView()
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
                EventsView()
            }
    }
}
