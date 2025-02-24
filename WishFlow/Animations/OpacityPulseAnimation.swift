//
//  OpacityPulseAnimation.swift
//  WishFlow
//
//  Created by Mees Akveld on 21/02/2025.
//

import Foundation
import SwiftUI

extension View {
    func opacityPulseEffect() -> some View {
        OpacityPulsingView(content: self)
    }
}

private struct OpacityPulsingView<Content: View>: View {
    let content: Content
    @State private var opacity: Double = 1.0

    var body: some View {
        content
            .opacity(opacity)
            .onAppear {
                withAnimation(Animation.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
                    opacity = 0.5
                }
            }
    }
}
