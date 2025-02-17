//
//  Fonts.swift
//  WishFlow
//
//  Created by Mees Akveld on 17/02/2025.
//

import Foundation
import SwiftUI

enum TextStyle {
    case text(Text)
    case textSmall(TextSmall)
    case title(Title)
    
    enum Title {
        case h1
        case h2
        case h3
    }
    
    enum Text {
        case regular
        case medium
        case bold
    }
    
    enum TextSmall {
        case regular
        case medium
    }
    
    func getFont() -> Font {
        switch self {
        case .title(let title):
            switch title {
            case .h1:
                return .custom("YesevaOne-Regular", size: 32)
            case .h2:
                return .custom("YesevaOne-Regular", size: 21.8)
            case .h3:
                return .custom("YesevaOne-Regular", size: 18.3)
            }
        case .text(let text):
            switch text {
            case .regular:
                return .custom("Poppins-Regular", size: 16)
            case .medium:
                return .custom("Poppins-Medium", size: 16)
            case .bold:
                return .custom("Poppins-Bold", size: 16)
            }
        case .textSmall(let textSmall):
            switch textSmall {
            case .regular:
                return .custom("Poppins-Regular", size: 12)
            case .medium:
                return .custom("Poppins-Medium", size: 12)
            }
        }
    }
}

extension View {
    
    func style(textStyle: TextStyle, color: Color) -> some View {
        self
            .style(color: color)
            .style(textStyle: textStyle)
    }
    
    func style(textStyle: TextStyle) -> some View {
        self
            .font(textStyle.getFont())
    }
    
    func style(color: Color) -> some View {
        self
            .foregroundStyle(color)
    }
}
