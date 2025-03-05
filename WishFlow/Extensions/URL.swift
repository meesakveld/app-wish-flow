//
//  URL.swift
//  WishFlow
//
//  Created by Mees Akveld on 05/03/2025.
//

import Foundation
import SwiftSoup
import SwiftUI

// Structure to represent the response of the function
struct PageData {
    var title: String?
    var openGraphData: OpenGraphData?
    var jsonLD: [JSONLDData]?
}

// OpenGraphData struct
struct OpenGraphData: Codable {
    var title: String?
    var image: String?
    var url: String?
    var description: String?
    
    init(from ogTags: [String: String]) {
        self.title = ogTags["og:title"]
        self.image = ogTags["og:image"]
        self.url = ogTags["og:url"]
        self.description = ogTags["og:description"]
    }
}

// JSONLDData struct
struct JSONLDData {
    var name: String?
    var description: String?
    var image: String?
    var price: CGFloat?
    var priceCurrency: String?
    
    init(from json: [String: Any]) {
        self.name = json["name"] as? String
        self.description = json["description"] as? String
        
        // Get the image URL
        if let imageDict = json["image"] as? [String: Any] {
            self.image = imageDict["url"] as? String
        } else if let imageUrl = json["image"] as? String {
            self.image = imageUrl
        }
        
        // Process the 'offers' object
        if let offers = json["offers"] as? [String: Any] {
            if let priceString = offers["price"] as? String {
                if let doublePrice = Double(priceString) {
                    self.price = CGFloat(doublePrice)
                }
            } else if let priceDouble = offers["price"] as? Double {
                self.price = CGFloat(priceDouble)
            }
            self.priceCurrency = offers["priceCurrency"] as? String
        }
    }
}


extension URL {
    
    // Gets the HTML and parses it into a `Document`
    private func fetchHTML() -> Document? {
        guard let data = try? Data(contentsOf: self), let html = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        do {
            let document = try SwiftSoup.parse(html)
            return document
        } catch {
            print("Fout bij parsen van HTML: \(error)")
            return nil
        }
    }
    
    // Extracts the Open Graph tags from a parsed HTML document
    private func fetchOGTags(from document: Document) -> [String: String] {
        var ogTags: [String: String] = [:]
        do {
            let metaTags = try document.select("meta[property^=og:]")
            for tag in metaTags {
                let property = try tag.attr("property")
                let content = try tag.attr("content")
                if !property.isEmpty, !content.isEmpty {
                    ogTags[property] = content
                }
            }
        } catch {
            print("Error retrieving OG tags: \(error)")
        }
        return ogTags
    }
    
    // Extracts the JSON-LD data from a parsed HTML document
    private func fetchJSONLD(from document: Document) -> [JSONLDData]? {
        do {
            if let scriptTag = try document.select("script[type=application/ld+json]").first() {
                var jsonLDContent = try scriptTag.html()
                
                jsonLDContent = cleanJSONString(jsonLDContent)
                
                // Zet JSON-string om naar een object of array van dictionaries
                if let jsonData = jsonLDContent.data(using: .utf8) {
                    // Probeer het eerst te parsen als een array
                    if let jsonArray = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [[String: Any]] {
                        return jsonArray.map { JSONLDData(from: $0) }
                    }
                    // Als het geen array is, probeer het dan als een enkel object
                    else if let jsonDict = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                        return [JSONLDData(from: jsonDict)]
                    }
                }
            }
        } catch {
            print("Error retrieving JSON-LD: \(error)")
        }
        return nil
    }
    
    // Gets the page title from a parsed HTML document
    private func fetchTitle(from document: Document) -> String? {
        do {
            return try document.title()
        } catch {
            print("Error retrieving title: \(error)")
            return nil
        }
    }
    
    // Function to clean JSON-LD string
    private func cleanJSONString(_ jsonString: String) -> String {
        var cleanedString = jsonString
        
        // Remove HTML comments
        cleanedString = cleanedString.replacingOccurrences(of: "<!--.*?-->", with: "", options: .regularExpression)
        
        // Remove extra whitespace from the beginning and end of the string
        cleanedString = cleanedString.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Remove invalid control characters (e.g. ASCII 0-31 and 127 or \n, \t, etc) but leave standard line breaks and tabs
        cleanedString = cleanedString.replacingOccurrences(of: #"[\x00-\x1F\x7F]"#, with: "", options: .regularExpression)
        
        return cleanedString
    }
    
    // Combined function to retrieve all data
    func getPageData() -> PageData? {
        guard let document = fetchHTML() else {
            return nil
        }
        
        let title = fetchTitle(from: document)
        let openGraphData = OpenGraphData(from: fetchOGTags(from: document))
        let jsonLD = fetchJSONLD(from: document)
        
        // Return the collected object
        return PageData(title: title, openGraphData: openGraphData, jsonLD: jsonLD)
    }
}
