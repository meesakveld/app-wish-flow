//
//  View.swift
//  WishFlow
//
//  Created by Mees Akveld on 17/02/2025.
//

import Foundation
import SwiftUI

extension View {
    
    @ViewBuilder
    func optModifiers<Content: View>(_ req: Bool, @ViewBuilder modifiers: (Self) -> Content) -> some View {
        if req { modifiers(self) } else { self }
    }
    
    @ViewBuilder
    func optModifiers<Content: View>(@ViewBuilder _ modifiers: (Self) -> Content) -> some View {
        modifiers(self)
    }
 
    func readSize(onChange: @escaping (_ height: Double, _ width: Double) -> Void) -> some View {
        background(
            GeometryReader { geometryProxy in
                Color.clear
                    .onAppear {
                        let width = Double(geometryProxy.size.width)
                        let height = Double(geometryProxy.size.height)
                        onChange(height, width)
                    }
            }
        )
    }
}
