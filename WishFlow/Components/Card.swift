//
//  Card.swift
//  WishFlow
//
//  Created by Mees Akveld on 23/02/2025.
//

import SwiftUI

struct Card: View {
    let title: String
    let image: String
    let bgColor: Color
    
    var body: some View {
        DropEffect {
            HStack {
                VStack(alignment: .leading) {
                    Text(title)
                        .style(textStyle: .title(.h1), color: .cBlack)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                    
                    HStack {
                        Text("See all")
                        Image(systemName: "arrow.right")
                    }
                    .style(textStyle: .textSmall(.regular), color: .cBlack)
                    
                    Image(image)
                        .offset(x: -40, y: -5)
                        .rotationEffect(.degrees(-20))
                }
                
                Spacer()
            }
            .padding([.top, .horizontal], 25)
            .frame(maxWidth: .infinity)
            .background(bgColor)
        }
    }
}

#Preview {
    Card(title: "Wishlist", image: "giftWithStars", bgColor: .cBlue)
}
