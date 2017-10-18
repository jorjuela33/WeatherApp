//
//  ParameterEncoding.swift
//  WeatherApp
//
//  Created by Jorge Orjuela on 10/18/17.
//

import Foundation

typealias JSONDictionary = [String: Any]

enum HTTPMethod: String {
    case DELETE
    case GET
    case POST
    case PUT
}

enum ParameterEncoding {
    case json
    case url
    
    // MARK: Instance methods
    
    /// Creates a URL request by encoding parameters and applying them onto an existing request.
    ///
    /// URLRequest - The request to have parameters applied
    /// parameters - The parameters to apply
    func encode(_ request: URLRequest, parameters: Any?) -> (URLRequest, NSError?) {
        var mutableURLRequest = request
        guard let parameters = parameters else {
            return (request, nil)
        }
        
        var encodingError: NSError?
        
        switch self {
        case .json:
            do {
                let data = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
                if mutableURLRequest.value(forHTTPHeaderField: "Content-Type") == nil {
                    mutableURLRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
                }
                mutableURLRequest.httpBody = data
            } catch {
                encodingError = error as NSError
            }
            
        case .url:
            if
                /// parameters
                let parameters = parameters as? JSONDictionary,

                /// raw string http method
                let httpMethod = mutableURLRequest.httpMethod,

                /// http method
                let method = HTTPMethod(rawValue: httpMethod), parameters.isEmpty == false {

                if
                    /// url
                    let url = mutableURLRequest.url,

                    /// url components
                    var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false), allowEncodingInURL(method) {

                        let existingQuery = (urlComponents.percentEncodedQuery.map { $0 + "&" } ?? "")
                        let percentEncodedQuery = existingQuery + queryString(parameters)
                        urlComponents.percentEncodedQuery = percentEncodedQuery
                        mutableURLRequest.url = urlComponents.url

                } else {
                    mutableURLRequest.setValue("application/x-www-form-urlencoded; charset=utf-8",
                                               forHTTPHeaderField: "Content-Type")
                    mutableURLRequest.httpBody = queryString(parameters).data(using: String.Encoding.utf8)
                }
            }
        }
        
        return (mutableURLRequest, encodingError)
    }
    
    // MARK: Private methods
    
    private func allowEncodingInURL(_ method: HTTPMethod) -> Bool {
        switch method {
        case .GET, .DELETE:
            return true
        default:
            return false
        }
    }
    
    private func queryString(_ parameters: [String: Any]) -> String {
        var components: [String] = []
        
        for key in parameters.keys.sorted(by: <) {
            guard let component = parameters[key] else { continue }
            
            components += queryComponent(key, component: component)
        }
        
        return components.joined(separator: "&")
    }
    
    private func queryComponent(_ key: String, component: Any) -> [String] {
        var components: [String] = []
        
        if let dictionary = component as? [String: Any] {
            for (nestedKey, value) in dictionary {
                components += queryComponent("\(key)[\(nestedKey)]", component: value)
            }
        } else if let array = component as? [Any] {
            for value in array {
                components += queryComponent("\(key)[]", component: value)
            }
        } else {
            components.append("\(scape(key))=\(scape("\(component)"))")
        }
        
        return components
    }
    
    private func scape(_ string: String) -> String {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/"
        let subDelimitersToEncode = "!$&'()*+,;="
        var allowedCharacterSet = CharacterSet.urlQueryAllowed
        allowedCharacterSet.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        return string.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) ?? string
    }
}
