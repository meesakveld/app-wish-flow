//
//  CheckForDiff.swift
//  WishFlow
//
//  Created by Mees Akveld on 11/03/2025.
//

import Foundation

/// Compares two optional values and returns `newValue` if it differs from `oldValue`.
/// If the values are the same, the function returns `nil`.
///
/// - Parameters:
///   - oldValue: The previous value of type `T?`.
///   - newValue: The new value of type `T?`.
/// - Returns: `newValue` if it differs from `oldValue`, otherwise `nil`.
///
/// ## Example Usage:
/// ```swift
/// let previousName: String? = "Alice"
/// let currentName: String? = "Bob"
/// if let updatedName = checkForDiff(oldValue: previousName, newValue: currentName) {
///     print("Value changed to: \(updatedName)") // Output: "Value changed to: Bob"
/// }
/// ```
func checkForDiff<T: Equatable>(oldValue: T?, newValue: T?) -> T? {
    if oldValue != newValue { return newValue }
    return nil
}
