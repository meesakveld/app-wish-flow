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
    
    struct FontStyle {
        let font: String
        let fontSize: CGFloat
        let lineHeight: CGFloat
    }

    func getFontStyle() -> FontStyle {
        switch self {
        case .title(let title):
            switch title {
            case .h1:
                return FontStyle(font: "YesevaOne-Regular", fontSize: 32, lineHeight: 32.2)
            case .h2:
                return FontStyle(font: "YesevaOne-Regular", fontSize: 21.8, lineHeight: 21.8)
            case .h3:
                return FontStyle(font: "YesevaOne-Regular", fontSize: 18.3, lineHeight: 18.3)
            }
        case .text(let text):
            switch text {
            case .regular:
                return FontStyle(font: "Poppins-Regular", fontSize: 16, lineHeight: 25)
            case .medium:
                return FontStyle(font: "Poppins-Medium", fontSize: 16, lineHeight: 25)
            case .bold:
                return FontStyle(font: "Poppins-Bold", fontSize: 16, lineHeight: 25)
            }
        case .textSmall(let textSmall):
            switch textSmall {
            case .regular:
                return FontStyle(font: "Poppins-Regular", fontSize: 14, lineHeight: 20)
            case .medium:
                return FontStyle(font: "Poppins-Medium", fontSize: 14, lineHeight: 20)
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
        let fontStyle = textStyle.getFontStyle()
        return self
            .font(.custom(fontStyle.font, size: fontStyle.fontSize))
            .lineSpacing(fontStyle.lineHeight - fontStyle.fontSize)
    }
    
    func style(color: Color) -> some View {
        self
            .foregroundStyle(color)
    }
}
