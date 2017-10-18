//
//  URLRequest+Additions.swift
//  WeatherApp
//
//  Created by Jorge Orjuela on 10/18/17.
//

import Foundation

extension URLRequest {
    
    // MARK: Initialization
    
    init(url: URL, method: HTTPMethod, contentType: String = "application/json", headers: [String: String] = [:]) {
        self.init(url: url)
        self.httpMethod = method.rawValue
        self.allHTTPHeaderFields = headers
        setValue(contentType, forHTTPHeaderField: "Content-Type")
        setValue("keep-alive", forHTTPHeaderField: "Connection")
    }
}
