//
//  Avatar.swift
//  WishFlow
//
//  Created by Mees Akveld on 26/02/2025.
//

import SwiftUI
import StrapiSwift

struct Avatar: View {
    let image: StrapiImage?
    var width: CGFloat = 44
    
    init(image: StrapiImage?) {
        self.image = image
    }
    
    init(image: StrapiImage?, width: CGFloat) {
        self.image = image
        self.width = width
    }
    
    var body: some View {
        ZStack {
            Image("avatarPlaceholder")
                .resizable()
                .frame(width: width, height: width)
                .scaledToFill()
                .aspectRatio(1, contentMode: .fit)
            
            if let url = image?.formats?.thumbnail?.url {
                AsyncImage(url: URL(string: url)) { image in
                    image.resizable()
                        .scaledToFill()
                } placeholder: {
                    ProgressView()
                }
                .frame(width: width, height: width)
                .clipShape(Circle())
            }
        }
        .overlay(Circle().stroke(Color.cForeground, lineWidth: 2))
    }
}

#Preview {
    Avatar(image: nil)
}
