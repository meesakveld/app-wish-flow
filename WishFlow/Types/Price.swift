//
//  Price.swift
//  WishFlow
//
//  Created by Mees Akveld on 24/02/2025.
//

import Foundation

struct Price: Codable {
    var id: Int
    var amount: Double
    var currency: Currency?
    
    func formatted() -> String {
        let currency: String? = currency?.symbol
        return (currency != nil) ? "\(currency ?? "") \(amount)" : "\(amount)"
    }
}
