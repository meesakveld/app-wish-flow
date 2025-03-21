//
//  EventCard.swift
//  WishFlow
//
//  Created by Mees Akveld on 24/02/2025.
//

import SwiftUI

@MainActor
class EventCardViewModel: ObservableObject {
    let user: User? = AuthenticationManager.shared.user
    
    init() {
        if user == nil { Task { await AuthenticationManager.shared.logout() } }
    }
}

struct EventCard: View {
    @StateObject var vm: EventCardViewModel = EventCardViewModel()
    let event: Event
    
    var body: some View {
        DropEffect {
            VStack {
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
                            .stroke(Color.cBlack, lineWidth: 2)
                    }
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text(event.title)
                                .style(textStyle: .text(.medium), color: .cBlack)
                                .lineLimit(1)
                            
                            Text(event.eventDate.dateToStringFormatter(DateFormat: .EEE_comma_MMM_dd_yyyy))
                                .style(textStyle: .textSmall(.regular), color: .cBlack)
                        }
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                }
                
                if let (text, sfSymbol) = event.getStatus(userId: vm.user?.id ?? 0) {
                    HStack(alignment: .firstTextBaseline) {
                        Image(systemName: sfSymbol)
                        
                        Text(text)
                            .multilineTextAlignment(.leading)
                        
                        Spacer()
                    }
                    .style(textStyle: .textSmall(.regular), color: .cBlack)
                    .padding(7.5)
                    .frame(maxWidth: .infinity)
                    .background(Color.cYellow)
                    .overlay {
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.cBlack, lineWidth: 3)
                            .foregroundStyle(Color.clear)
                    }
                    .cornerRadius(5)
                }
            }
            .padding(15)
            .background(event.eventDate.isTodayOrFuture() ? Color.cPurple : Color.cBlue)
        }
    }
}

#Preview {
    EventCard(event: Event())
}
