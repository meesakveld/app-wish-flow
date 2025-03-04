//
//  SortLabel.swift
//  WishFlow
//
//  Created by Mees Akveld on 04/03/2025.
//

import SwiftUI
import StrapiSwift

struct SortLabel: View {
    let icon: String
    let state: SortOperator
    let filterOn: String
    let action: () -> Void
    
    init(icon: String, state: SortOperator, filterOn: String, _ action: @escaping () -> Void) {
        self.icon = icon
        self.state = state
        self.filterOn = filterOn
        self.action = action
    }
    
    var body: some View {
        Button {
            action()
        } label: {
            DropEffect {
                HStack(alignment: .center, spacing: 0) {
                    VStack {
                        Image(systemName: icon)
                            .resizable()
                            .scaledToFit()
                    }
                    .padding(10)
                    .background(Color.cOrange)
                    .border(width: 1.5, edges: [.trailing], color: .cBlack)
                    .frame(maxWidth: 35, maxHeight: 35)
                    
                    HStack {
                        Image(systemName: state.getSFSymbol())
                            .frame(maxWidth: 35, maxHeight: 35)
                        
                        Text(state.getFullName())
                            .style(textStyle: .textSmall(.regular), color: .cBlack)
                        
                        Spacer()
                        
                    }
                    .padding(.horizontal, 10)
                    .fixedSize(horizontal: true, vertical: false)
                }
                .background(Color.cWhite)
            }
        }
        .contextMenu {
            Label(filterOn, systemImage: icon)
        } preview: {
            self.padding(5)
        }
    }
}

#Preview {
    SortLabel(icon: "calendar", state: .ascending, filterOn: "Filter on price") {
        
    }
}
