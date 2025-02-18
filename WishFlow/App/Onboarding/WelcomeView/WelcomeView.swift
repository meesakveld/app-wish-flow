//
//  WelcomeView.swift
//  WishFlow
//
//  Created by Mees Akveld on 17/02/2025.
//

import SwiftUI

struct WelcomeView: View {
    var body: some View {
        VStack {
            Spacer()
            
            VStack(alignment: .leading, spacing: 24) {
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Welcome to Wishflow")
                        .style(textStyle: .title(.h1), color: .cForeground)
                    
                    Text("WishFlow makes it easy to manage wish lists and gift groups for any occasion. With features like visibility settings and gift assignments, users can prevent duplicate presents and ensure a smooth gifting experience.")
                        .style(textStyle: .text(.regular), color: .cForeground)
                }
                
                HStack(spacing: 16) {
                    NavigationLink {
                        RegisterView()
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
                    
                    NavigationLink {
                        LoginView()
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
        }
        .padding(.horizontal)
        .background(Color.cBackground)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    WelcomeView()
}
