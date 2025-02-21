//
//  RegisterView.swift
//  WishFlow
//
//  Created by Mees Akveld on 18/02/2025.
//

import SwiftUI
import StrapiSwift

struct RegisterView: View {
    @ObservedObject var vm: RegisterViewModel = RegisterViewModel()
    @EnvironmentObject private var navigationManager: NavigationManager
    
    // Form entries
    @State var email: String = ""
    @State var username: String = ""
    @State var firstname: String = ""
    @State var lastname: String = ""
    @State var password: String = ""
    @State var passwordConfirmation: String = ""
    
    var body: some View {
        ScrollView {
            
            VStack(alignment: .leading, spacing: 24) {
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Create an account")
                        .style(textStyle: .title(.h1), color: .cForeground)
                    
                    Text("Create an account to manage your wish lists and gift groups. Sign up now and start planning the perfect gifts!")
                        .style(textStyle: .text(.regular), color: .cForeground)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                FormWrapper { isLoading, setFormError, entriesErrors, isShowingEntriesErrors in
                    
                    VStack(alignment: .leading, spacing: 24) {
                        
                        VStack(alignment: .leading, spacing: 16) {
                            TextEntry(
                                identifier: "firstname",
                                value: $firstname,
                                title: "First name",
                                placeholder: "Enter your first name",
                                errors: entriesErrors,
                                isShowingErrors: isShowingEntriesErrors.wrappedValue
                            )
                            
                            TextEntry(
                                identifier: "lastname",
                                value: $lastname,
                                title: "Last name",
                                placeholder: "Enter your last name",
                                errors: entriesErrors,
                                isShowingErrors: isShowingEntriesErrors.wrappedValue
                            )
                            
                            TextEntry(
                                identifier: "email",
                                value: $email,
                                title: "Email",
                                placeholder: "Enter email",
                                errors: entriesErrors,
                                isShowingErrors: isShowingEntriesErrors.wrappedValue
                            )
                            
                            TextEntry(
                                identifier: "username",
                                value: $username,
                                title: "Username",
                                placeholder: "Enter username",
                                errors: entriesErrors,
                                isShowingErrors: isShowingEntriesErrors.wrappedValue
                            )
                            
                            TextEntry(
                                identifier: "password",
                                value: $password,
                                title: "Password",
                                placeholder: "Enter password",
                                errors: entriesErrors,
                                isShowingErrors: isShowingEntriesErrors.wrappedValue,
                                isSecureField: true
                            )
                            
                            TextEntry(
                                identifier: "confirmation",
                                value: $passwordConfirmation,
                                title: "Password confirmation",
                                placeholder: "Enter password again",
                                errors: entriesErrors,
                                isShowingErrors: isShowingEntriesErrors.wrappedValue,
                                isSecureField: true
                            )
                        }
                        .loadingEffect(isLoading.wrappedValue)
                        
                        HStack(spacing: 16) {
                            Button {
                                Task {
                                    setLoading(value: isLoading, .isLoading)
                                    setFormError(nil)
                                    isShowingEntriesErrors.wrappedValue = true
                                    
                                    if entriesErrors.wrappedValue.isEmpty {
                                        guard password == passwordConfirmation else {
                                            setFormError("Passwords do not match.")
                                            return setLoading(value: isLoading, .finished)
                                        }
                                        
                                        do {
                                            try await vm.register(email: email, username: username, firstname: firstname, lastname: lastname, password: password)
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
                                    
                                    setLoading(value: isLoading, .finished)
                                }
                            } label: {
                                DropEffect {
                                    HStack {
                                        Text("Register")
                                            .style(textStyle: .text(.medium), color: .cBlack)
                                            .padding(15)
                                    }
                                    .frame(maxWidth: .infinity, maxHeight: 50)
                                    .background(Color.cBlue)
                                }
                            }
                        }
                        
                    }
                }
            }
            .padding(.bottom)
            .padding(.horizontal)
        }
        .background(Color.cBackground.ignoresSafeArea())
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    RegisterView()
        .environmentObject(NavigationManager())
}
