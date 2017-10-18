//
//  DataResponseSerializer.swift
//  WeatherApp
//
//  Created by Jorge Orjuela on 10/18/17.
//

import Foundation

public struct DataResponseSerializer: ResponseSerializer {
    
    // MARK: ResponseSerializer
    
    public func serialize(request: URLRequest?,
                          response: HTTPURLResponse?,
                          data: Data, errors: [Error]) -> Result<Data> {

        if let error = errors.first { return Result.failure(error) }
        
        if let response = response, emptyResponseCodes.contains(response.statusCode) {
            return .success(data)
        }
        
        guard !data.isEmpty else {
            return .failure(URLRequestOperationError.inputDataNilOrZeroLength)
        }
        
        return .success(data)
    }
}
