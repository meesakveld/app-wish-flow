//
//  EventTypeCard.swift
//  WishFlow
//
//  Created by Mees Akveld on 10/03/2025.
//

import SwiftUI

struct EventTypeCard: View {
    let title: String
    let description: LocalizedStringKey
    let example: String
    let backgroundColor: Color
    
    var body: some View {
        DropEffect {
            HStack {
                VStack(alignment: .leading, spacing: 15) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text(title)
                            .style(textStyle: .title(.h3), color: .cBlack)
                        
                        Text(description)
                            .style(textStyle: .textSmall(.medium), color: .cBlack)
                            .multilineTextAlignment(.leading)
                    }
                    
                    Text(example)
                        .style(textStyle: .textSmall(.regular), color: .cBlack)
                }
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding(15)
            .background(backgroundColor)
        }
    }
}

#Preview {
    EventTypeCard(
        title: "Single Recipient",
        description: "A gifting occasion where **one person** receives gifts from others.",
        example: "E.g. Birthday, Baby Shower",
        backgroundColor: .cBlue
    )
}
