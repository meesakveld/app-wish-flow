//
//  LoadingState.swift
//  WishFlow
//
//  Created by Mees Akveld on 21/02/2025.
//

import Foundation
import SwiftUI

enum LoadingState {
    case readyToLoad
    case isLoading
    case finished
    
    func getBool() -> Bool {
        switch self {
        case .readyToLoad:
            return false
        case .isLoading:
            return true
        case .finished:
            return false
        }
    }
}

func setLoading(value: Binding<LoadingState>, _ to: LoadingState, _ delay: TimeInterval = 1.0) -> Void {
    switch to {
    case .readyToLoad:
        value.wrappedValue = .readyToLoad
    case .isLoading:
        if value.wrappedValue != .finished {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                if value.wrappedValue != .finished {
                    value.wrappedValue = .isLoading
                }
            }
        }
    case .finished:
        value.wrappedValue = .finished
    }
}

extension View {
    func loadingEffect(_ loadingState: LoadingState) -> some View {
        return self
            .optModifiers(loadingState.getBool()) { VStack in
                VStack
                    .disabled(true)
                    .redacted(reason: .placeholder)
                    .modifier(OpacityPulseAnimation())
            }
    }
}
