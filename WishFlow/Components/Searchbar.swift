//
//  Searchbar.swift
//  WishFlow
//
//  Created by Mees Akveld on 23/02/2025.
//

import SwiftUI

struct Searchbar: View {
    @Binding var search: String
    
    var body: some View {
        DropEffect {
            HStack(spacing: 0) {
                Image(systemName: "magnifyingglass")
                    .font(.custom("", fixedSize: 20))
                    .frame(minHeight: 48)
                    .foregroundStyle(.cForeground)
                    .padding(.horizontal, 12)
                    .background(Color.cGreen)
                    .border(Color.black)
                
                TextField("Search an event", text: $search)
                    .style(textStyle: .text(.regular), color: .black)
                    .frame(maxWidth: .infinity, minHeight: 48)
                    .padding(.horizontal, 10)
                    .background(Color.cWhite)
                    .multilineTextAlignment(.leading)
            }
        }
    }
}

#Preview {
    Searchbar(search: .constant(""))
}
