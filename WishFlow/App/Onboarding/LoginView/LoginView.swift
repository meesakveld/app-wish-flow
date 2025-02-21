//
//  LoginView.swift
//  WishFlow
//
//  Created by Mees Akveld on 18/02/2025.
//

import SwiftUI
import StrapiSwift

struct LoginView: View {
    @ObservedObject var vm: LoginViewModel = LoginViewModel()
    @EnvironmentObject private var navigationManager: NavigationManager
    
    @State var identifier: String = ""
    @State var password: String = ""
    
    var body: some View {
        
        GeometryReader { geometry in
            
            ScrollView {
                
                VStack {
                    Spacer()
                    
                    VStack(alignment: .leading, spacing: 24) {
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Login to your account")
                                .style(textStyle: .title(.h1), color: .cForeground)
                            
                            Text("Welcome back to WishFlow! Log in to manage your wish lists, join gift groups, and stay updated on your gifting plans.")
                                .style(textStyle: .text(.regular), color: .cForeground)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        
                        FormWrapper { inputsErrors, isShowingInputsErrors in
                            Group {
                                TextEntry(
                                    identifier: "identifier",
                                    value: $identifier,
                                    title: "Email or username",
                                    placeholder: "Enter email or username",
                                    errors: inputsErrors,
                                    isShowingErrors: isShowingInputsErrors
                                )
                                
                                TextEntry(
                                    identifier: "password",
                                    value: $password,
                                    title: "Password",
                                    placeholder: "Enter password",
                                    errors: inputsErrors,
                                    isShowingErrors: isShowingInputsErrors,
                                    isSecureField: true
                                )
                            }
                        } submit: { setIsLoading, setFormError, inputsErrors, isShowingInputsErrors in
                            Button {
                                Task {
                                    setIsLoading(.isLoading)
                                    setFormError(nil)
                                    isShowingInputsErrors.wrappedValue = true

                                    if inputsErrors.isEmpty {
                                        do {
                                            try await vm.login(identifier: identifier, password: password)
                                            navigationManager.navigate(to: .home)
                                        } catch let error as StrapiSwiftError {
                                            switch error {
                                            case .badResponse(_, let message):
                                                setFormError(message)
                                            default:
                                                setFormError("Something went wrong")
                                            }
                                        } catch {
                                            print(error)
                                            setFormError("Something went wrong")
                                        }
                                    }

                                    setIsLoading(.finished)
                                }
                            } label: {
                                DropEffect {
                                    HStack {
                                        Text("Login")
                                            .style(textStyle: .text(.medium), color: .cBlack)
                                            .padding(15)
                                    }
                                    .frame(maxWidth: .infinity, maxHeight: 50)
                                    .background(Color.cGreen)
                                }
                            }
                        }
                    }
                    .padding(.bottom)
                    .padding(.horizontal)
                }
                .frame(minHeight: geometry.size.height)
            }
            .background(Color.cBackground)
            .frame(maxWidth: .infinity, maxHeight: geometry.size.height)
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(NavigationManager())
}
