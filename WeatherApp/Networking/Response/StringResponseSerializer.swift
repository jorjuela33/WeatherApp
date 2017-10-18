//
//  StringResponseSerializer.swift
//  WeatherApp
//
//  Created by Jorge Orjuela on 10/18/17.
//

import Foundation

public struct StringResponseSerializer: ResponseSerializer {
    
    private var encoding: String.Encoding
    
    // MARK: Initialization
    
    init(encoding: String.Encoding = .utf8) {
        self.encoding = encoding
    }
    
    // MARK: ResponseSerializer
    
    public func serialize(request: URLRequest?,
                          response: HTTPURLResponse?,
                          data: Data, errors: [Error]) -> Result<String> {

        if let error = errors.first { return Result.failure(error) }
        
        if let response = response, emptyResponseCodes.contains(response.statusCode) {
            return .success("")
        }
        
        guard !data.isEmpty else {
            return .failure(URLRequestOperationError.inputDataNilOrZeroLength)
        }
        
        guard let stringResponse = String(data: data, encoding: encoding) else {
            return .failure(URLRequestOperationError.stringSerializationFailed(encoding: encoding))
        }
        
        return .success(stringResponse)
    }
}
