//
//  TextEntry.swift
//  WishFlow
//
//  Created by Mees Akveld on 18/02/2025.
//

import SwiftUI

struct TextEntry: View {
    let identifier: String
    
    @Binding var value: String
    
    let title: String
    let placeholder: String
    @Binding var errors: [TextEntryError]
    let isSecureField: Bool
    let isOptionalField: Bool
    
    @State private var isSecure: Bool
    
    init(identifier: String, value: Binding<String>, title: String, placeholder: String, errors: Binding<[TextEntryError]>? = nil, isSecureField: Bool = false, isOptionalField: Bool = false) {
        self.identifier = identifier
        self._value = value
        self.title = title
        self.placeholder = placeholder
        self._errors = errors ?? .constant([])
        self.isSecureField = isSecureField
        self.isOptionalField = isOptionalField
        self._isSecure = State(initialValue: isSecureField)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            
            // MARK: - Title
            Text(title + (isOptionalField ? " (optional)" : ""))
                .style(textStyle: .text(.medium), color: .cForeground)
            
            // MARK: - TextField + SecureField Toggle
            HStack {
                if isSecure {
                    SecureField(placeholder, text: $value)
                        .style(textStyle: .text(.regular), color: .cBlack)
                        .textInputAutocapitalization(.never)
                } else {
                    TextField(placeholder, text: $value)
                        .style(textStyle: .text(.regular), color: .cBlack)
                        .textInputAutocapitalization(.never)
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
            if !errors.isEmpty {
                let errorsOfTextField = errors
                    .filter { $0.identifier == identifier }
                    .map((\.message))
                
                if !errorsOfTextField.isEmpty {
                    Text(errorsOfTextField.first!)
                        .style(textStyle: .text(.medium), color: .cOrange)
                }
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        TextEntry(identifier: "email", value: .constant(""), title: "Email", placeholder: "Enter email")
        TextEntry(
            identifier: "email",
            value: .constant(""),
            title: "Password",
            placeholder: "Enter password",
            errors: .constant([
                TextEntryError(identifier: "email", message: "Email is required")
            ]),
            isSecureField: true
        )
    }
    .padding()
}
