//
//  DropEffect.swift
//  WishFlow
//
//  Created by Mees Akveld on 17/02/2025.
//

import SwiftUI

struct DropEffect<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    @State private var size: CGSize = .zero
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 7.5)
                .foregroundStyle(.cBlack)
                .frame(width: size.width, height: size.height)
                .offset(x: 5, y: 5)
                .padding(.trailing, 5)
            
            content
                .background(
                    GeometryReader { proxy in
                        Color.cBackground
                            .onAppear {
                                size = proxy.size
                            }
                            .onChange(of: proxy.size) { oldSize, newSize in
                                size = newSize
                            }
                    }
                )
                .overlay {
                    RoundedRectangle(cornerRadius: 7.5)
                        .stroke(Color.cBlack, lineWidth: 3)
                        .foregroundStyle(Color.clear)
                }
                .cornerRadius(7.5)
                .padding(.trailing, 5)
        }
        .padding(.bottom, 5)
    }
}

#Preview {
    DropEffect {
        VStack {
            Text("Voorbeeldtekst")
                .padding(10)
        }
        .padding(15)
        .background(Color.cOrange)
    }
}
