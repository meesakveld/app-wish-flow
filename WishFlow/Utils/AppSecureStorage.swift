//
//  AppSecureStorage.swift
//  WishFlow
//
//  Created by Mees Akveld on 20/02/2025.
//

import Foundation
import SwiftUI
import SwiftKeychainWrapper

@propertyWrapper
public struct AppSecureStorage: DynamicProperty {

    private let key: String
    private let accessibility: KeychainItemAccessibility

    public var wrappedValue: String? {
        get {
            KeychainWrapper.standard.string(forKey: key, withAccessibility: self.accessibility)
        }
        nonmutating set {
            if let newValue, !newValue.isEmpty {
                let success = KeychainWrapper.standard.set(newValue, forKey: key, withAccessibility: self.accessibility)
                if !success {
                    print("⚠️ Error: Could not save value to Keychain for key: \(key)")
                }
            } else {
                let success = KeychainWrapper.standard.removeObject(forKey: key, withAccessibility: self.accessibility)
                if !success {
                    print("⚠️ Error: Could not remove value from Keychain for key: \(key)")
                }
            }
        }
    }

    public init(_ key: String, accessibility: KeychainItemAccessibility = .afterFirstUnlockThisDeviceOnly) {
        self.key = key
        self.accessibility = accessibility
    }
}

@propertyWrapper
public struct AppStorageData<T: Codable>: DynamicProperty {
    private let key: String
    @AppStorage private var storedData: Data?

    public init(_ key: String) {
        self.key = key
        self._storedData = AppStorage(key)
    }
    
    public var wrappedValue: T? {
        get {
            guard let data = storedData else { return nil }
            return try? JSONDecoder().decode(T.self, from: data)
        }
        nonmutating set {
            storedData = try? JSONEncoder().encode(newValue)
        }
    }
}
