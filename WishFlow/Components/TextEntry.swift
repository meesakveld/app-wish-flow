//
//  TextEntry.swift
//  WishFlow
//
//  Created by Mees Akveld on 18/02/2025.
//

import SwiftUI

struct TextEntry: View {
    
    @Binding var value: String
    
    let title: String
    let placeholder: String
    let error: String?
    let isSecureField: Bool
    
    @State private var isSecure: Bool
    
    init(value: Binding<String>, title: String, placeholder: String, error: String? = nil, isSecureField: Bool = false) {
        self._value = value
        self.title = title
        self.placeholder = placeholder
        self.error = error
        self.isSecureField = isSecureField
        self._isSecure = State(initialValue: isSecureField)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            
            // MARK: - Title
            Text(title)
                .style(textStyle: .text(.medium), color: .cForeground)
            
            // MARK: - TextField + SecureField Toggle
            HStack {
                if isSecure {
                    SecureField(placeholder, text: $value)
                        .style(textStyle: .text(.regular), color: .cBlack)
                } else {
                    TextField(placeholder, text: $value)
                        .style(textStyle: .text(.regular), color: .cBlack)
                }
                
                // Switch between secure en normal textfield.
                if isSecureField {
                    Button(action: {
                        isSecure.toggle()
                    }) {
                        Image(systemName: isSecure ? "eye.slash" : "eye")
                            .foregroundColor(.gray)
                    }
                    .padding(.trailing, 10)
                }
            }
            .foregroundStyle(Color.cBlack)
            .frame(height: 44)
            .padding(.horizontal, 15)
            .background(Color.cWhite)
            .cornerRadius(7.5)
            .overlay(
                RoundedRectangle(cornerRadius: 7.5)
                    .stroke(Color.cBlack, lineWidth: 2)
            )
            
            // MARK: - Error
            if let error = error {
                Text(error)
                    .style(textStyle: .text(.medium), color: .cOrange)
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        TextEntry(value: .constant(""), title: "Email", placeholder: "Enter email")
        TextEntry(value: .constant(""), title: "Password", placeholder: "Enter password", error: "Error is required.", isSecureField: true)
    }
    .padding()
}
