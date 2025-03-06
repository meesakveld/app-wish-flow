//
//  ValidatedHttpsUrl.swift
//  WishFlow
//
//  Created by Mees Akveld on 05/03/2025.
//

import Foundation

func validatedHttpsUrl(from urlString: String) throws -> URL {
    guard let encodedString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
          let url = URL(string: encodedString) else {
        throw NSError(domain: "URLValidation", code: 1, userInfo: [NSLocalizedDescriptionKey: "The URL is invalid: \(urlString)"])
    }
    
    guard url.scheme == "https" else {
        throw NSError(domain: "URLValidation", code: 2, userInfo: [NSLocalizedDescriptionKey: "The URL is not secure. Please use an https URL."])
    }
    
    return url
}
