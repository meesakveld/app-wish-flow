//
//  TextEntry.swift
//  WishFlow
//
//  Created by Mees Akveld on 18/02/2025.
//

import SwiftUI
import PhotosUI

struct ImageEntry: View {
    let identifier: String
    let title: String
    
    @Binding var value: UIImage?
    let valueURL: String?
    
    @Binding var errors: [TextEntryError]
    let isShowingErrors: Bool

    let isOptionalField: Bool
        
    init(
        identifier: String,
        title: String,
        value: Binding<UIImage?>,
        valueURL: String? = nil,
        errors: Binding<[TextEntryError]>? = nil,
        isShowingErrors: Bool = false,
        isOptionalField: Bool = false
    ) {
        self.identifier = identifier
        self.title = title
        self._value = value
        self.valueURL = valueURL
        self._errors = errors ?? .constant([])
        self.isShowingErrors = isShowingErrors
        self.isOptionalField = isOptionalField
    }
    
    @State private var imageSelection: PhotosPickerItem? = nil
    
    private func setImage(from selection: PhotosPickerItem?) {
        guard let selection else { return }
        
        Task {
            if let data = try? await selection.loadTransferable(type: Data.self) {
                if let uiImage = UIImage(data: data) {
                    value = uiImage
                    return
                }
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            
            // MARK: - Title
            Text(title + (isOptionalField ? " (optional)" : ""))
                .style(textStyle: .text(.medium), color: .cForeground)
            
            // MARK: - Image
            HStack {
                PhotosPicker(selection: $imageSelection, matching: .images) {
                    if let image = value {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                    } else if let urlString = valueURL, let url = URL(string: urlString) {
                        AsyncImage(url: url) { image in
                            image.resizable()
                                .scaledToFill()
                        } placeholder: {
                            ProgressView()
                        }
                    } else {
                        VStack(alignment: .center, spacing: 10) {
                            Image(systemName: "photo")
                                .font(.custom("", fixedSize: 40))
                            
                            Text("Select image")
                                .style(textStyle: .text(.regular))
                        }
                        .foregroundStyle(.cBlack.opacity(0.3))
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 10)
                    }
                }
                .onChange(of: imageSelection, { oldValue, newValue in
                    setImage(from: imageSelection)
                })
                .frame(height: 200)
                .frame(maxWidth: .infinity)
            }
            .foregroundStyle(Color.cBlack)
            .background(Color.cWhite)
            .cornerRadius(7.5)
            .overlay(
                RoundedRectangle(cornerRadius: 7.5)
                    .stroke(Color.cBlack, lineWidth: 2)
            )
            .onAppear {
                if !isOptionalField && value == nil && valueURL == nil {
                    if !errors.contains(where: { $0.identifier == identifier }) {
                        errors.append(TextEntryError(identifier: identifier, message: "\(title) is required."))
                    }
                }
            }
            .onChange(of: value) { _, _ in
                if !isOptionalField {
                    if value != nil || valueURL != nil {
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

