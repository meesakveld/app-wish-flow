//
//  DateFormatter.swift
//  WishFlow
//
//  Created by Mees Akveld on 18/02/2025.
//

import Foundation

extension DateFormatter {
    
    static let iso8601WithMilliseconds: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ" // Supports milliseconds
        formatter.locale = Locale(identifier: "en_US_POSIX") // Prevents locale-related issues
        formatter.timeZone = TimeZone(secondsFromGMT: 0) // Ensures 'Z' is correctly interpreted as UTC
        return formatter
    }()
    
}
