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
                            .collection("currencies")
                            .withDocumentId("y1itvxj3ky3vp1jcnkstks6v")
                            .getDocument()
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
