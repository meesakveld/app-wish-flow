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
    let isShowingErrors: Bool
    
    let entryType: TextEntryType
    let isOptionalField: Bool
    
    @State private var isSecure: Bool
    @FocusState private var isFocused: Bool
    
    init(identifier: String, value: Binding<String>, title: String, placeholder: String, errors: Binding<[TextEntryError]>? = nil, isShowingErrors: Bool = false, entryType: TextEntryType = .textField, isOptionalField: Bool = false) {
        self.identifier = identifier
        self._value = value
        self.title = title
        self.placeholder = placeholder
        self._errors = errors ?? .constant([])
        self.isShowingErrors = isShowingErrors
        self.entryType = entryType
        self.isOptionalField = isOptionalField
        self._isSecure = State(initialValue: entryType.isSecureField)
    }
    
    enum TextEntryType {
        case textField
        case secureField
        case textEditor(lineLimit: CGFloat)
        
        var isSecureField: Bool {
            if case .secureField = self { return true }
            return false
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            
            // MARK: - Title
            Text(title + (isOptionalField ? " (optional)" : ""))
                .style(textStyle: .text(.medium), color: .cForeground)
            
            // MARK: - TextField + SecureField Toggle
            HStack {
                switch entryType {
                case .textField:
                    TextField(placeholder, text: $value)
                        .style(textStyle: .text(.regular), color: .cBlack)
                        .textInputAutocapitalization(.never)
                        .frame(height: 44)
                case .secureField:
                    SecureField(placeholder, text: $value)
                        .style(textStyle: .text(.regular), color: .cBlack)
                        .textInputAutocapitalization(.never)
                        .frame(height: 44)
                case .textEditor(let lineLimit):
                    TextEditor(text: $value)
                        .style(textStyle: .text(.regular), color: value == placeholder ? .cBlack.opacity(0.3) : .cBlack)
                        .frame(height: 5 + (lineLimit * 33) + 5)
                        .onAppear { if value.isEmpty { value = placeholder } }
                        .focused($isFocused)
                        .onChange(of: isFocused) { _, _ in
                            withAnimation {
                                if value == placeholder { value = "" } else if value.isEmpty { value = placeholder }
                            }
                        }
                }
                
                // Switch between secure en normal textfield.
                if entryType.isSecureField {
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
            .padding(.horizontal, 15)
            .background(Color.cWhite)
            .cornerRadius(7.5)
            .overlay(
                RoundedRectangle(cornerRadius: 7.5)
                    .stroke(Color.cBlack, lineWidth: 2)
            )
            .onAppear {
                    if !isOptionalField && (value.isEmpty || value == placeholder) {
                        if !errors.contains(where: { $0.identifier == identifier }) {
                            errors.append(TextEntryError(identifier: identifier, message: "\(title) is required."))
                        }
                    }
            }
            .onChange(of: value) { _, _ in
                if !isOptionalField {
                    if !value.isEmpty && value != placeholder {
                        errors = errors.filter { $0.identifier != identifier && $0.message != "\(title) is required." }
                    } else {
                        errors.append(TextEntryError(identifier: identifier, message: "\(title) is required."))
                    }
                }
            }
            
            // MARK: - Error
            if !errors.isEmpty && isShowingErrors {
                let errorsOfTextField = errors
                    .filter { $0.identifier == identifier }
                    .map(\.message)
                
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
            entryType: .secureField
        )
        TextEntry(
            identifier: "description",
            value: .constant(""),
            title: "Description",
            placeholder: "Enter description",
            errors: .constant([]),
            entryType: .textEditor(lineLimit: 5)
        )
    }
    .padding()
}
