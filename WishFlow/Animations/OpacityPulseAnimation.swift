//
//  OpacityPulseAnimation.swift
//  WishFlow
//
//  Created by Mees Akveld on 21/02/2025.
//

import Foundation
import SwiftUI

extension View {
    // Pulsatie-effect voor opacity toevoegen als modifier
    func opacityPulseEffect() -> some View {
        self
            .modifier(OpacityPulseAnimation())
    }
}


struct OpacityPulseAnimation: ViewModifier {
    @State private var opacity: Double = 1.0
    
    func body(content: Content) -> some View {
        content
            .opacity(opacity) // Variabele opacity toepassen
            .animation(
                Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true),
                value: opacity
            )
            .onAppear {
                opacity = 0.3 // Start met lage opacity
            }
            .onChange(of: opacity) { _, _ in
                // Zorg ervoor dat de animatie heen en weer blijft bewegen
                withAnimation {
                    opacity = opacity == 0.3 ? 1.0 : 0.3
                }
            }
    }
}
