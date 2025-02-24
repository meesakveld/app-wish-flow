//
//  HomeView.swift
//  WishFlow
//
//  Created by Mees Akveld on 20/02/2025.
//

import SwiftUI
import StrapiSwift

struct HomeView: View {
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
                            .scaledToFill()
                            .frame(width: 44, height: 44)
                        
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
                    
                }
                
                Button {
                    Task {
                        do {
                            
                            let result = try await Strapi.contentManager
                                .collection("events")
                                .populate("image")
                                .populate("minBudget") { minBudget in
                                    minBudget.populate("currency")
                                }
                                .populate("maxBudget") { maxBudget in
                                    maxBudget.populate("currency")
                                }
                                .populate("gifts")
                                .populate("eventParticipants")
                                .populate("giftClaims")
                                .populate("eventAssignments")
                                .populate("eventInvites")
                                .getDocuments(as: [Event].self)
                            
                            print("Result \(result)")
                        } catch {
                            print(error)
                        }
                    }
                } label: {
                    Text("GET")
                }
                
                
                Button {
                    AuthenticationManager.shared.logout()
                } label: {
                    Text("Logout")
                }
                
            }
        }
        .padding(.horizontal)
        .background(Color.cBackground.ignoresSafeArea())
    }
}

#Preview {
    HomeView()
        .environmentObject(NavigationManager())
}
