//
//  Decoder.swift
//  WishFlow
//
//  Created by Mees Akveld on 23/02/2025.
//

import Foundation

// Decoder extension for reusing the decodeDate function
extension Decoder {
    // This function will work for any CodingKey type, which is specific to the struct.
    func decodeDate<T: CodingKey>(from container: KeyedDecodingContainer<T>, forKey key: T, using formatter: DateFormatter) throws -> Date {
        let dateString = try container.decode(String.self, forKey: key)
        guard let date = formatter.date(from: dateString) else {
            throw DecodingError.dataCorruptedError(forKey: key, in: container, debugDescription: "Invalid date format: \(dateString)")
        }
        return date
    }
    
    func decodeDateIfPresent<T: CodingKey>(from container: KeyedDecodingContainer<T>, forKey key: T, using formatter: DateFormatter) throws -> Date? {
        if let dateString = try container.decodeIfPresent(String.self, forKey: key) {
            guard let date = formatter.date(from: dateString) else {
                throw DecodingError.dataCorruptedError(forKey: key, in: container, debugDescription: "Invalid date format: \(dateString)")
            }
            return date
        }
        return nil
    }
}

