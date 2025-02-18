//
//  RegisterView.swift
//  WishFlow
//
//  Created by Mees Akveld on 18/02/2025.
//

import SwiftUI

struct RegisterView: View {
    @State var email: String = ""
    @State var username: String = ""
    @State var password: String = ""
    @State var passwordConfirmation: String = ""
    
    var body: some View {
        VStack {
            Spacer()
            
            VStack(alignment: .leading, spacing: 24) {
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Create an account")
                        .style(textStyle: .title(.h1), color: .cForeground)
                    
                    Text("Create an account to manage your wish lists and gift groups. Sign up now and start planning the perfect gifts!")
                        .style(textStyle: .text(.regular), color: .cForeground)
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    TextEntry(
                        identifier: "email",
                        value: $email,
                        title: "Email",
                        placeholder: "Enter email"
                    )
                    
                    TextEntry(
                        identifier: "username",
                        value: $username,
                        title: "Username",
                        placeholder: "Enter username"
                    )
                    
                    TextEntry(
                        identifier: "password",
                        value: $password,
                        title: "Password",
                        placeholder: "Enter password",
                        isSecureField: true
                    )
                    
                    TextEntry(
                        identifier: "confirmation",
                        value: $passwordConfirmation,
                        title: "Password confirmation",
                        placeholder: "Enter password again",
                        isSecureField: true
                    )
                }
                
                HStack(spacing: 16) {
                    Button {
                        print("register")
                    } label: {
                        DropEffect {
                            HStack {
                                Text("Register")
                                    .style(textStyle: .text(.bold), color: .cBlack)
                                    .padding(15)
                            }
                            .frame(maxWidth: .infinity, maxHeight: 50)
                            .background(Color.cBlue)
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
    RegisterView()
}
