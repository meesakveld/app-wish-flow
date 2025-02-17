//
//  Date.swift
//  WishFlow
//
//  Created by Mees Akveld on 17/02/2025.
//

import Foundation

public enum DateFormat: String {
    case dd_MM_yyyy = "dd-MM-yyyy" // Example: 04-03-2024
    case MM_dd_yyyy = "MM-dd-yyyy" // Example: 03-04-2024
    case dd_MM_yyyy_slash = "dd/MM/yyyy" // Example: 04/03/2024
    case MM_dd_yyyy_slash = "MM/dd/yyyy" // Example: 03/04/2024
    case yyyy_MM_dd = "yyyy-MM-dd" // Example: 2024-03-04
    case yyyyMMdd = "yyyyMMdd" // Example: 20240304
    case ddMMyyyy = "ddMMyyyy" // Example: 04032024
    case MMddyyyy = "MMddyyyy" // Example: 03042024
    case dd_MMMM_yyyy = "dd MMMM yyyy" // Example: 04 March 2024
    case MMMM_dd_yyyy_comma = "MMMM dd, yyyy" // Example: March 04, 2024
    case MMM_dd_yyyy = "MMM dd yyyy" // Example: Mar 04 2024
    case dd_MMM_yyyy = "dd MMM yyyy" // Example: 04 Mar 2024
    case MMM_yyyy_dd = "MMM yyyy dd" // Example: Mar 2024 04
    case EEEE_comma_dd_MMMM_yyyy = "EEEE, dd MMMM yyyy" // Example: Monday, 04 March 2024
    case EEE_comma_MMM_dd_yyyy = "EEE, MMM dd yyyy" // Example: Mon, Mar 04 2024
    case dd_MM_yyyy_mm_hh = "dd-MM-yyyy HH:mm" // Example: 04-03-2024 12:30
    case mm_hh = "HH:mm" // Example: 12:30
    case mmhh = "HHmm" // Example: 1230
    case RFC3339 = "yyyy-MM-dd'T'HH:mm:ssZ" // RFC 3339 format: Example: 2024-07-16T10:30:45Z
}

extension Date {
    
    func dateToStringFormatter(DateFormat: DateFormat) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = DateFormat.rawValue
        return dateFormatter.string(from: self)
    }
    
    func addFifteenMinutes() -> Date {
        return self.addingTimeInterval(15 * 60) // 15 minuten in seconden
    }
    
    func subtractFifteenMinutes() -> Date {
        return self.addingTimeInterval(-15 * 60) // 15 minuten in seconden
    }
    
}
