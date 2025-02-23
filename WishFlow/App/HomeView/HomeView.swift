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
    
    var body: some View {
        ScrollView {
            VStack {
                Button {
                    AuthenticationManager.shared.logout()
                } label: {
                    Text("Uitloggen")
                }
                
                Button {
                    Task {
                        do {
                            let data: StrapiRequestBody = StrapiRequestBody([
                                "event": .int(1),
                                "invitedUserEmail": .string("akveldmees@gmail.com")
                            ])
                            
                            let result = try await Strapi.contentManager.collection("event-invites").postData(data, as: String.self)
                            print(result)
                        } catch {
                            print(error)
                        }
                    }
                } label: {
                    Text("Add invite")
                }
                
                Button {
                    Task {
                        do {
                            let data: StrapiRequestBody = StrapiRequestBody([
                                "title": .string("Event titel nieuw")
                            ])
                            
                            let result = try await Strapi.contentManager
                                .collection("events")
                                .withDocumentId("evzjtxte3fxlvkx7w15q5lhp")
                                .putData(data, as: String.self)
                            print(result)
                            
                        } catch {
                            print(error)
                        }
                    }
                } label: {
                    Text("Update event")
                }
            }
        }
        .background(Color.cBackground.ignoresSafeArea())
    }
}

#Preview {
    HomeView()
        .environmentObject(NavigationManager())
}
