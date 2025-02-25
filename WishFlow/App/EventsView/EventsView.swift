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
    @Published var eventsIsLoading: LoadingState = .preparingToLoad
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
            let strapiResponse = try await EventManager.shared.getUpcomingEventsWithUserIdWithSearchSortedByEventDateAndPagination(
                userId: user!.id,
                search: search,
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
                Searchbar(search: $vm.search, autoFocus: searchActivated)
                    .onChange(of: vm.search, { _, _ in
                        Task {
                            await vm.getEvents(isLoading: $vm.eventsIsLoading)
                        }
                    })
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
                                    .frame(maxWidth: 35)
                                    
                                    HStack {
                                        Image(systemName: vm.sortEventDate.getSFSymbol())
                                        Text(vm.sortEventDate.getFullName())
                                    }
                                    .style(textStyle: .textSmall(.regular), color: .cBlack)
                                    .padding(.trailing, 10)
                                }
                            }
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
                                .loadingEffect(.isLoading)
                        }
                    }
                    
                    if (vm.events.isEmpty ? !vm.eventsIsLoading.isInLoadingState() : !vm.eventsIsLoading.isLoading()) && !vm.eventsHasError {
                        //MARK: Events array
                        ForEach(vm.events, id: \.documentId) { event in
                            EventCard(event: event)
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
