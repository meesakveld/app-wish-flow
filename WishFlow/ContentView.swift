//
//  ContentView.swift
//  WishFlow
//
//  Created by Mees Akveld on 03/02/2025.
//

import SwiftUI
import StrapiSwift

struct ContentView: View {
    var body: some View {
        HStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.orange)
            Text("Hello, world!")
                .style(textStyle: .text(.regular), color: .blue)
        }
        .background(Color.green)
        .onAppear {
            Task {
                do {
//                    let result = try await Strapi.contentManager
//                        .collection("events")
//                        .populate("event_participant") { event_participant in
//                            event_participant
//                                .populate("user")
//                        }
//                        .getDocuments(as: String.self)
                    
//                    let user = try await Strapi.authentication
//                        .local
//                        .login(
//                            identifier: "meesakveld@gmail.com",
//                            password: "secret321",
//                            as: String.self
//                        )
                    
//                    let register = try await Strapi.authentication
//                        .local
//                        .register(
//                            username: "akveldmees",
//                            email: "akveldmees@gmail.com",
//                            password: "secret123",
//                            as: String.self
//                        )
                    
//                    let newPassword = try await Strapi.authentication
//                        .local
//                        .changePassword(
//                            currentPassword: "secret321",
//                            newPassword: "secret123",
//                            as: String.self
//                        )
                           
                    
                } catch {
                    print(error)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
