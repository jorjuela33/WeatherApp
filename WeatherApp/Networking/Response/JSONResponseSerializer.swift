//
//  JSONResponseSerializer.swift
//  WeatherApp
//
//  Created by Jorge Orjuela on 10/18/17.
//

import Foundation

struct JSONResponseSerializer: ResponseSerializer {

    private var readingOptions: JSONSerialization.ReadingOptions
    
    // MARK: Initialization
    
    init(readingOptions: JSONSerialization.ReadingOptions = .allowFragments) {
        self.readingOptions = readingOptions
    }
    
    // MARK: ResponseSerializer
    
    public func serialize(request: URLRequest?,
                          response: HTTPURLResponse?,
                          data: Data, errors: [Error]) -> Result<Any> {

        if let error = errors.first { return Result.failure(error) }
        
        if let response = response, emptyResponseCodes.contains(response.statusCode) {
            return .success(NSNull())
        }
        
        guard !data.isEmpty else {
            return .failure(URLRequestOperationError.inputDataNilOrZeroLength)
        }
        
        do {
            let serializedObject = try JSONSerialization.jsonObject(with: data, options: readingOptions)
            return .success(serializedObject)
        } catch {
            return .failure(URLRequestOperationError.jsonSerializationFailed(error: error))
        }
    }
}
