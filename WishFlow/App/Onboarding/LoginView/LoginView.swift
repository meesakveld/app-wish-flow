//
//  LoginView.swift
//  WishFlow
//
//  Created by Mees Akveld on 18/02/2025.
//

import SwiftUI

struct LoginView: View {
    @State var email: String = ""
    @State var password: String = ""
    
    var body: some View {
        VStack {
            Spacer()
            
            VStack(alignment: .leading, spacing: 24) {
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Login to your account")
                        .style(textStyle: .title(.h1), color: .cForeground)
                    
                    Text("Welcome back to WishFlow! Log in to manage your wish lists, join gift groups, and stay updated on your gifting plans.")
                        .style(textStyle: .text(.regular), color: .cForeground)
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    TextEntry(
                        value: $email,
                        title: "Email",
                        placeholder: "Enter email"
                    )
                    
                    TextEntry(
                        value: $password,
                        title: "Password",
                        placeholder: "Enter password",
                        isSecureField: true
                    )
                }
                
                HStack(spacing: 16) {
                    Button {
                        print("login")
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
}
