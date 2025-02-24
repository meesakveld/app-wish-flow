//
//  EventCard.swift
//  WishFlow
//
//  Created by Mees Akveld on 24/02/2025.
//

import SwiftUI

struct EventCard: View {
    let event: Event
    
    var body: some View {
        DropEffect {
            HStack(spacing: 15) {
                ZStack {
                    Color.cYellow
                        .frame(width: 66, height: 66)
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                    
                    if let url = event.image?.formats?.small?.url {
                        AsyncImage(url: URL(string: url)) { image in
                            image.resizable()
                                .scaledToFill()
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(width: 66, height: 66)
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                    }
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color.cForeground, lineWidth: 2)
                }
                
                HStack {
                    VStack(alignment: .leading) {
                        Text(event.title)
                            .style(textStyle: .text(.medium), color: .cBlack)
                        
                        Text(event.eventDate.dateToStringFormatter(DateFormat: .EEE_comma_MMM_dd_yyyy))
                            .style(textStyle: .textSmall(.regular), color: .cBlack)
                    }
                    Spacer()
                }
                .frame(maxWidth: .infinity)
            }
            .padding(15)
            .background(Color.cPurple)
        }
    }
}

#Preview {
    EventCard(event: Event())
}
