//
//  EventsView.swift
//  WishFlow
//
//  Created by Mees Akveld on 23/02/2025.
//

import SwiftUI
import StrapiSwift

@MainActor
class EventsViewModel: ObservableObject {
    let user: User? = AuthenticationManager.shared.user
    
    @Published var events: [Event] = []
    @Published var eventsIsLoading: LoadingState = .readyToLoad
    @Published var eventsHasError: Bool = false
    
    @Published var search: String = ""
    @Published var sortEventDate: SortOperator = .descending { didSet { activeSort = .date } }
    @Published private(set) var activeSort: ActiveSortOperator = .date
    
    enum ActiveSortOperator {
        case date
    }
    
    func getEvents(isLoading: Binding<LoadingState>) async {
        eventsHasError = false
        setLoading(value: isLoading, .isLoading)
        do {
            let strapiResponse = try await EventManager.shared.getUpcomingEventsWithUserIdSortedByEventDateAndPagination(
                userId: user!.id,
                sortEventDate: sortEventDate,
                page: 1,
                pageSize: 100
            )
            events = strapiResponse.data
        } catch {
            eventsHasError = true
            print(error)
        }
        setLoading(value: isLoading, .finished)
    }
    
}

struct EventsView: View {
    @ObservedObject var vm: EventsViewModel = EventsViewModel()
    
    let user: User? = AuthenticationManager.shared.user
    @State var search = ""
    
    var body: some View {
        ScrollView {
            VStack(spacing: 40) {
                
                // MARK: - Header
                HStack(alignment: .center) {
                    Text("Events")
                        .style(textStyle: .title(.h1), color: .cForeground)
                }
                .padding(.horizontal)
                
                // MARK: - Search
                VStack(alignment: .leading, spacing: 10) {
                    Searchbar(search: $vm.search)
                        .padding(.horizontal)
                    
                    // MARK: Sort & filter
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            Button {
                                vm.sortEventDate.toggle()
                            } label: {
                                DropEffect {
                                    HStack(alignment: .center) {
                                        VStack {
                                            Image(systemName: "calendar")
                                                .resizable()
                                                .scaledToFit()
                                        }
                                        .padding(10)
                                        .background(Color.cOrange)
                                        .border(Color.cBlack)
                                        
                                        HStack {
                                            Image(systemName: vm.sortEventDate.getSFSymbol())
                                            Text(vm.sortEventDate.getFullName())
                                        }
                                        .style(textStyle: .textSmall(.regular), color: .cBlack)
                                        .padding(.trailing, 10)
                                    }
                                    .frame(minHeight: 30)
                                }
                            }
                            .disabled(vm.eventsIsLoading.isInLoadingState())
                        }
                        .padding(.horizontal)
                    }
                    .onChange(of: vm.sortEventDate) { _, _ in
                        Task {
                            await vm.getEvents(isLoading: $vm.eventsIsLoading)
                        }
                    }
                }
                
                
                // MARK: - Events
                VStack {
                    
                    LazyVStack(spacing: 13) {
                        //MARK: Loading placeholders
                        if vm.eventsIsLoading.isLoading() {
                            ForEach(0...2, id: \.self) { _ in
                                EventCard(event: Event())
                                    .loadingEffect(.isLoading)
                            }
                        }
                        
                        if !vm.eventsIsLoading.isInLoadingState() && !vm.eventsHasError {
                            //MARK: Upcoming events array
                            ForEach(vm.events, id: \.documentId) { event in
                                EventCard(event: event)
                            }
                            
                            //MARK: No upcoming events
                            if vm.events.isEmpty {
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
                        }
                        
                        //MARK: Error message
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
                .onAppear {
                    Task {
                        await vm.getEvents(isLoading: $vm.eventsIsLoading)
                    }
                }
                .padding(.horizontal)
                
            }
        }
        .toolbar {
            Button {
                print("add event")
            } label: {
                Image(systemName: "plus.circle")
            }
            
            Button {
                print("add event")
            } label: {
                Image(systemName: "ellipsis.circle")
            }
            
        }
        .refreshable {
            Task {
                //                await vm.getUpcomingEvents(isLoading: $vm.upcomingEventsIsLoading)
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
