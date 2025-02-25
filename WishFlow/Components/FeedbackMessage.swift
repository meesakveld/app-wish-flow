//
//  FeedbackMessage.swift
//  WishFlow
//
//  Created by Mees Akveld on 25/02/2025.
//

import SwiftUI

struct FeedbackMessage<Content: View>: View {
    let image: String
    let text: String
    let content: Content
    
    init(image: String, text: String, @ViewBuilder _ content: () -> Content) {
        self.image = image
        self.text = text
        self.content = content()
    }
    
    var body: some View {
        VStack(spacing: 25) {
            Image(image)
                .resizable()
                .scaledToFit()
                .frame(width: 120)
            
            Text(text)
                .style(textStyle: .text(.regular), color: .cForeground)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 25)
            
            content

        }
        .padding(.top, 15)
    }
}

#Preview {
    FeedbackMessage(
        image: "event",
        text: "No upcoming events planned — why not plan something fun?"
    ) {
        Button {
            print("refresh")
        } label: {
            HStack {
                Image(systemName: "arrow.clockwise.circle")
                
                Text("Refresh")
            }
            .style(textStyle: .text(.regular), color: .cOrange)
        }
    }
}
