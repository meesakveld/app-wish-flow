//
//  LoadingState.swift
//  WishFlow
//
//  Created by Mees Akveld on 21/02/2025.
//

import Foundation
import SwiftUI

/// An enum representing the different stages of a loading process.
/// The possible states are:
/// - `readyToLoad`: The data is ready to be loaded, but the loading process hasn't started yet.
/// - `preparingToLoad`: Preparations are being made before the actual loading begins.
/// - `isLoading`: The data is currently being loaded.
/// - `finished`: The loading process has been completed.
enum LoadingState {
    case readyToLoad, preparingToLoad, isLoading, finished
    
    /// Returns a boolean value indicating if the loading process is ongoing.
    /// - Returns: `true` if the state is `isLoading`, otherwise `false`.
    ///
    /// Example:
    /// ```
    /// let state = LoadingState.isLoading
    /// print(state.getBool()) // true
    /// ```
    func isLoading() -> Bool {
        switch self {
        case .isLoading:
            return true
        default:
            return false
        }
    }
    
    /// Checks if the current state is one of the loading states (`preparingToLoad` or `isLoading`).
    /// - Returns: `true` if the state is either `preparingToLoad` or `isLoading`, otherwise `false`.
    ///
    /// Example:
    /// ```
    /// let state = LoadingState.preparingToLoad
    /// print(state.isLoadingState()) // true
    /// ```
    func isInLoadingState() -> Bool {
        switch self {
        case .preparingToLoad, .isLoading:
            return true
        default:
            return false
        }
    }
}

func setLoading(value: Binding<LoadingState>, _ to: LoadingState, _ delay: TimeInterval = 1.0) -> Void {
    switch to {
    case .readyToLoad:
        value.wrappedValue = .readyToLoad
    case .preparingToLoad:
        value.wrappedValue = .preparingToLoad
    case .isLoading:
        // Reset value
        if value.wrappedValue == .finished {
            value.wrappedValue = .preparingToLoad
        }
        
        // Set timer to update value to .isLoading
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
            .optModifiers(loadingState.isLoading()) { VStack in
                VStack
                    .redacted(reason: .placeholder)
                    .opacityPulseEffect()
            }
    }
}
