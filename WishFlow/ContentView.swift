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
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .onAppear {
            Task {
                do {
                    print(
                        try await Strapi.contentManager
                            .collection("events")
                            .populate("event_participant") { item in
                                item
                                    .populate("user") { user in
                                        user
                                            .populate("event_participant") { event_participant in
                                                event_participant
                                                    .populate("event")
                                            }
                                    }
                            }
                            .getDocuments()
                    )
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
