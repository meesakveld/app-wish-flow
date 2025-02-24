//
//  HomeView.swift
//  WishFlow
//
//  Created by Mees Akveld on 20/02/2025.
//

import SwiftUI
import StrapiSwift

@MainActor
class HomeViewModel: ObservableObject {
    @Published var upcomingEvents: [Event] = []
    @Published var isLoadingUpcomingEvents: LoadingState = .readyToLoad
    
    @AppStorageData("user") var user: User?
    
    func getUpcomingEvents(isLoading: Binding<LoadingState>) async {
        setLoading(value: isLoading, .isLoading)
        do {
            upcomingEvents = try await EventManager.shared.getUpcomingEvents(userId: user!.id)
        } catch {
            print(error)
        }
        setLoading(value: isLoading, .finished)
    }
}

struct HomeView: View {
    @ObservedObject var vm: HomeViewModel = HomeViewModel()
    @EnvironmentObject private var navigationManager: NavigationManager
    
    let user: User? = AuthenticationManager.shared.user
    @State var search = ""
    
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
                    
                    ZStack {
                        Image("avatarPlaceholder")
                            .resizable()
                            .frame(width: 44, height: 44)
                            .scaledToFill()
                            .aspectRatio(1, contentMode: .fit)
                        
                        if let url = user?.avatar?.formats?.small?.url {
                            AsyncImage(url: URL(string: url)) { image in
                                image.resizable()
                                    .scaledToFill()
                            } placeholder: {
                                ProgressView()
                            }
                            .frame(width: 44, height: 44)
                            .clipShape(Circle())
                        }
                    }
                    .overlay(Circle().stroke(Color.cForeground, lineWidth: 2))
                    .padding(1)
                    .onTapGesture {
                        AuthenticationManager.shared.logout()
                    }
                }
                
                // MARK: - Search
                NavigationLink {
                    EventsView()
                } label: {
                    Searchbar(search: .constant(""))
                        .disabled(true)
                }
                
                
                // MARK: - Wistlist & Buylist
                HStack {
                    Card(title: "Wish\nlist", image: "giftWithStars", bgColor: .cBlue)
                    
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
                        let isLoading = vm.isLoadingUpcomingEvents.getBool()
                        
                        //MARK: Loading placeholders
                        if isLoading {
                            ForEach(0...2, id: \.self) { _ in
                                EventCard(event: Event())
                                    .loadingEffect(.isLoading)
                            }
                        }
                        
                        if !isLoading {
                            //MARK: Upcoming events array
                            ForEach(vm.upcomingEvents, id: \.documentId) { event in
                                EventCard(event: event)
                            }
                            
                            //MARK: No upcoming events
                            if vm.upcomingEvents.isEmpty {
                                VStack(spacing: 25) {
                                    Image("event")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 120)
                                    
                                    Text("No upcoming events planned — why not plan something fun?")
                                        .style(textStyle: .text(.regular), color: .cForeground)
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal, 25)
                                    
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
                                .padding(.top, 15)
                            }
                        }
                    }
                    
                }
                .onAppear {
                    Task {
                        await vm.getUpcomingEvents(isLoading: $vm.isLoadingUpcomingEvents)
                    }
                }
                
            }
            .padding(.horizontal)
        }
        .refreshable {
            Task {
                await vm.getUpcomingEvents(isLoading: $vm.isLoadingUpcomingEvents)
            }
        }
        .background(Color.cBackground.ignoresSafeArea())
    }
}

#Preview {
    HomeView()
        .environmentObject(NavigationManager())
}
