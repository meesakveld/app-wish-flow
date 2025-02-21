//
//  FormWrapper.swift
//  WishFlow
//
//  Created by Mees Akveld on 21/02/2025.
//

import SwiftUI

struct FormWrapper<TextEntries: View, Submit: View>: View {
    @State private var loadingState: LoadingState = .readyToLoad
    @State private var formError: String? = nil
    @State private var inputsErrors: [TextEntryError] = []
    @State private var isShowingInputsErrors: Bool = false
    
    let textEntries: (
                  _ inputsErrors: Binding<[TextEntryError]>,
                  _ isShowingInputsErrors: Bool) -> TextEntries
    
    let submit: (_ setIsLoading: @escaping (LoadingState) -> Void,
                  _ setFormError: @escaping (String?) -> Void,
                  _ inputsErrors: [TextEntryError],
                  _ isShowingInputsErrors: Binding<Bool>) -> Submit
    
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
            
            VStack(alignment: .leading, spacing: 24) {
                
                VStack(alignment: .leading, spacing: 16) {
                    textEntries(
                        $inputsErrors,
                        isShowingInputsErrors
                    )
                }
                .loadingEffect(loadingState)
                
                submit(
                    { newLoadingState in setLoading(value: $loadingState, newLoadingState) },
                    { newError in formError = newError },
                    inputsErrors,
                    $isShowingInputsErrors
                )
                
            }
            .disabled(loadingState.getBool())
        }
    }
}
