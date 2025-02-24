//
//  DateFormatter.swift
//  WishFlow
//
//  Created by Mees Akveld on 18/02/2025.
//

import Foundation

extension DateFormatter {
    
    /// A `DateFormatter` configured to handle ISO 8601 dates with milliseconds (`yyyy-MM-dd'T'HH:mm:ss.SSSZ`).
    /// - The format includes milliseconds and a timezone offset (e.g., `2025-02-18T15:34:45.123+0000`).
    /// - Uses `en_US_POSIX` locale to ensure consistent formatting across different regions.
    /// - Sets the time zone to UTC (`secondsFromGMT: 0`) to handle the 'Z' (UTC) correctly in the date string.
    static let iso8601WithMilliseconds: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ" // Supports milliseconds and timezone offset
        formatter.locale = Locale(identifier: "en_US_POSIX") // Prevents locale-related issues
        formatter.timeZone = TimeZone(secondsFromGMT: 0) // Ensures 'Z' is correctly interpreted as UTC
        return formatter
    }()
    
    /// A `DateFormatter` configured to handle dates in the `yyyy-MM-dd` format.
    /// - Uses `en_US_POSIX` locale to avoid regional differences in formatting.
    /// - Sets the time zone to UTC (`secondsFromGMT: 0`) to ensure consistent date interpretation.
    static let shortDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd" // Only year, month, and day
        formatter.locale = Locale(identifier: "en_US_POSIX") // Prevents locale-related issues
        formatter.timeZone = TimeZone(secondsFromGMT: 0) // Ensures consistent interpretation
        return formatter
    }()
    
}
