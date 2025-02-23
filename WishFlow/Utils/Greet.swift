//
//  Greet.swift
//  WishFlow
//
//  Created by Mees Akveld on 23/02/2025.
//

import Foundation

func greet() -> String {
    let calendar = Calendar.current
    let hour = calendar.component(.hour, from: Date())
    
    if hour >= 0 && hour < 12 {
        return "Good morning"
    } else if hour >= 12 && hour < 18 {
        return "Good afternoon"
    } else {
        return "Good evening"
    }
}
