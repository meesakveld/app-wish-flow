//
//  WishCard.swift
//  WishFlow
//
//  Created by Mees Akveld on 04/03/2025.
//

import SwiftUI

struct WishCard: View {
    let wish: Gift
    
    var body: some View {
        DropEffect {
            VStack(spacing: 15) {
                ZStack {
                    Color.cYellow
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                    
                    GeometryReader { geometry in
                        let size = geometry.size.width
                        if let url = wish.image?.getURL(size: .small)  {
                            AsyncImage(url: URL(string: url)) { image in
                                image.resizable()
                                    .scaledToFill()
                                    .frame(width: size, height: size)
                                    .clipped()
                            } placeholder: {
                                ProgressView()
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                        }
                    }
                }
                .aspectRatio(1, contentMode: .fit) // Zorgt ervoor dat items vierkant blijven
                .overlay {
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color.cForeground, lineWidth: 2)
                }
                
                HStack {
                    VStack(alignment: .leading) {
                        Text(wish.title)
                            .style(textStyle: .text(.medium), color: .cBlack)
                        
                        Text(wish.price?.formatted() ?? "€ 30")
                            .style(textStyle: .textSmall(.regular), color: .cBlack)
                    }
                    Spacer()
                }
                .frame(maxWidth: .infinity)
            }
            .padding(15)
            .background(Color.cBlue)
        }
    }
}
