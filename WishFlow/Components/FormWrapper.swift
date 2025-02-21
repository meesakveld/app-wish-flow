//
//  FormWrapper.swift
//  WishFlow
//
//  Created by Mees Akveld on 21/02/2025.
//

import SwiftUI

struct FormWrapper<Content: View>: View {
    @State private var loadingState: LoadingState = .readyToLoad
    @State private var formError: String? = nil
    @State private var errors: [TextEntryError] = []
    @State private var isShowingErrors: Bool = false
    
    let content: (_ isLoading: Binding<LoadingState>,
                  _ setFormError: @escaping (String?) -> Void,
                  _ entriesErrors: Binding<[TextEntryError]>,
                  _ isShowingEntriesErrors: Binding<Bool>) -> Content
    
    var body: some View {
        VStack(spacing: 16) {
            if let formError = formError, !formError.isEmpty {
                HStack {
                    Text(formError)
                        .padding(15)
                        .multilineTextAlignment(.leading)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .style(textStyle: .text(.medium), color: .cBlack)
                .background(Color.cOrange)
                .cornerRadius(7.5)
            }
            
            content(
                $loadingState,
                { newError in formError = newError },
                $errors,
                $isShowingErrors
            )
        }
    }
}

#Preview {
    FormWrapper { isLoading, setFormError, entriesErrors, isShowingEntriesErrors in
        VStack {
            Text("Preview Content")
                .onAppear {
                    setFormError("This is a test error")
                    isLoading.wrappedValue = .finished
                    entriesErrors.wrappedValue = [TextEntryError(identifier: "email", message: "Invalid input")]
                    isShowingEntriesErrors.wrappedValue = true
                }
            
            if isLoading.wrappedValue.getBool() {
                ProgressView()
            }
        }
    }
}
