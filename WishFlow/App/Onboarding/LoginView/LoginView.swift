//
//  LoginView.swift
//  WishFlow
//
//  Created by Mees Akveld on 18/02/2025.
//

import SwiftUI
import StrapiSwift

class LoginViewModel: ObservableObject {
    
    func login(identifier: String, password: String) async throws {
        try await AuthenticationManager.shared.login(identifier: identifier, password: password)
    }
    
}

struct LoginView: View {
    @ObservedObject var vm: LoginViewModel = LoginViewModel()
    @EnvironmentObject private var navigationManager: NavigationManager

    @State var identifier: String = ""
    @State var password: String = ""
    @State var errors: [TextEntryError] = []
    @State var isShowingErrors: Bool = false
    
    var body: some View {
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
                
                VStack(alignment: .leading, spacing: 16) {
                    TextEntry(
                        identifier: "identifier",
                        value: $identifier,
                        title: "Email or username",
                        placeholder: "Enter email or username",
                        errors: $errors,
                        isShowingErrors: isShowingErrors
                    )
                    
                    TextEntry(
                        identifier: "password",
                        value: $password,
                        title: "Password",
                        placeholder: "Enter password",
                        errors: $errors,
                        isShowingErrors: isShowingErrors,
                        isSecureField: true
                    )
                }
                
                HStack(spacing: 16) {
                    Button {
                        Task {
                            do {
                                isShowingErrors = true
                                if errors.isEmpty {
                                    try await vm.login(identifier: identifier, password: password)
                                    navigationManager.navigate(to: .home)
                                }
                            } catch {
                                print(error)
                            }
                        }
                    } label: {
                        DropEffect {
                            HStack {
                                Text("Login")
                                    .style(textStyle: .text(.bold), color: .cBlack)
                                    .padding(15)
                            }
                            .frame(maxWidth: .infinity, maxHeight: 50)
                            .background(Color.cGreen)
                        }
                    }
                }
            }
            .padding(.bottom)
        }
        .padding(.horizontal)
        .background(Color.cBackground)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    LoginView()
        .environmentObject(NavigationManager())
}
