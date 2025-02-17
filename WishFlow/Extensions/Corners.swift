//
//  Corners.swift
//  WishFlow
//
//  Created by Mees Akveld on 17/02/2025.
//

import Foundation
import SwiftUI

struct RoundedCorner: Shape {

    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
    
    
    func customCorners() -> some View {
        self
            .cornerRadius(5, corners: [.topLeft, .bottomRight])
            .cornerRadius(15, corners: [.topRight, .bottomLeft])
    }
}
