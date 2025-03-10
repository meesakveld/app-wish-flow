//
//  CheckCircle.swift
//  WishFlow
//
//  Created by Mees Akveld on 10/03/2025.
//

import SwiftUI

struct CheckCircle: View {
    let isChecked: Bool
    let action: () -> Void
    
    init(isChecked: Bool, _ action: @escaping () -> Void) {
        self.isChecked = isChecked
        self.action = action
    }
    
    var body: some View {
        Button {
            action()
        } label: {
            Image(systemName: isChecked ? "checkmark.circle.fill" : "circle")
                .resizable()
                .frame(width: 25, height: 25)
                .foregroundColor(isChecked ? .cOrange : .gray)
                .animation(.easeInOut(duration: 0.1), value: isChecked)
        }
    }
}

#Preview {
    CheckCircle(isChecked: true) {
        print("dsfdsfsd")
    }
}
