//
//  FormWrapper.swift
//  WishFlow
//
//  Created by Mees Akveld on 21/02/2025.
//

import SwiftUI

/// A generic form wrapper view that combines form fields and submission logic.
///
/// The `FormWrapper` component handles form validation, submission, and error handling.
/// It takes two closures as parameters: one for rendering the form fields (`textEntries`)
/// and another for handling the form submission (`submit`). It also provides state management
/// for loading, form errors, and input errors.
///
/// Example Usage:
///
/// ```swift
/// FormWrapper { inputsErrors, isShowingInputsErrors in
///     Group {
///         TextEntry(
///             identifier: "identifier",
///             value: $identifier,
///             title: "Email or username",
///             placeholder: "Enter email or username",
///             errors: inputsErrors,
///             isShowingErrors: isShowingInputsErrors
///         )
///
///         TextEntry(
///             identifier: "password",
///             value: $password,
///             title: "Password",
///             placeholder: "Enter password",
///             errors: inputsErrors,
///             isShowingErrors: isShowingInputsErrors,
///             isSecureField: true
///         )
///     }
/// } submit: { setIsLoading, setFormError, inputsErrors, isShowingInputsErrors in
///     Button {
///         Task {
///             setIsLoading(.isLoading)
///             setFormError(nil)
///             isShowingInputsErrors.wrappedValue = true
///
///             if inputsErrors.isEmpty {
///                 do {
///                     try await vm.login(identifier: identifier, password: password)
///                     navigationManager.navigate(to: .home)
///                 } catch let error as StrapiSwiftError {
///                     switch error {
///                     case .badResponse(_, let message):
///                         setFormError(message)
///                     default:
///                         setFormError("Something went wrong")
///                     }
///                 } catch {
///                     print(error)
///                     setFormError("Something went wrong")
///                 }
///             }
///
///             setIsLoading(.finished)
///         }
///     } label: {
///         DropEffect {
///             HStack {
///                 Text("Login")
///                     .style(textStyle: .text(.medium), color: .cBlack)
///                     .padding(15)
///             }
///             .frame(maxWidth: .infinity, maxHeight: 50)
///             .background(Color.cGreen)
///         }
///     }
/// }
/// ```
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
                .loadingEffect(loadingState.isLoading())
                
                submit(
                    { newLoadingState in setLoading(value: $loadingState, newLoadingState) },
                    { newError in formError = newError },
                    inputsErrors,
                    $isShowingInputsErrors
                )
                
            }
            .disabled(loadingState.isInLoadingState())
        }
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
}
