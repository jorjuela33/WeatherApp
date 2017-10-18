//
//  URLDataRequestOperation.swift
//  WeatherApp
//
//  Created by Jorge Orjuela on 10/18/17.
//

import Foundation

class URLDataRequestOperation: URLRequestOperation {
    
    /// the data returned for the server
    private(set) var data = Data()
}

extension URLDataRequestOperation {
    
    // MARK: Response Serialization
    
    /// Returns a object contained in a result type constructed from the response serializer passed as parameter.
    @discardableResult
    func response<Serializer: ResponseSerializer>(data: Data,
                                                  queue: DispatchQueue = DispatchQueue.main,
                                                  responseSerializer: Serializer,
                                                  completionHandler: @escaping ((Result<Serializer.SerializedValue>) -> Void)) -> Self {
        
        operationQueue.addOperation {
            queue.async {
                let result = responseSerializer.serialize(request: self.task.originalRequest,
                                                          response: self.response,
                                                          data: self.data,
                                                          errors: self.errors)
                completionHandler(result)
            }
        }
        return self
    }
    
    /// Adds a handler to be called once the request has finished.
    @discardableResult
    public func responseData(queue: DispatchQueue = DispatchQueue.main, completionHandler: @escaping ((Result<Data>) -> Void)) -> Self {
        return response(data: data, queue: queue, responseSerializer: DataResponseSerializer(), completionHandler: completionHandler)
    }
    
    /// Returns a JSON object contained in a result type constructed from the response data using `JSONSerialization`
    /// with the specified reading options.
    @discardableResult
    func responseJSON(readingOptions: JSONSerialization.ReadingOptions = .allowFragments,
                      queue: DispatchQueue = DispatchQueue.main,
                      completionHandler: @escaping ((Result<Any>) -> Void)) -> Self {

        return response(data: data,
                        queue: queue,
                        responseSerializer: JSONResponseSerializer(readingOptions: readingOptions),
                        completionHandler: completionHandler)
    }
    
    /// Returns a string object contained in a result type constructed from the response data using `String.Encoding`
    /// with the specified encoding options.
    @discardableResult
    func responseString(encoding: String.Encoding = .utf8,
                        queue: DispatchQueue = DispatchQueue.main,
                        completionHandler: @escaping ((Result<String>) -> Void)) -> Self {

        return response(data: data, queue: queue, responseSerializer: StringResponseSerializer(encoding: .utf8), completionHandler: completionHandler)
    }
}

extension URLDataRequestOperation: URLSessionDataDelegate {
    
    // MARK: NSURLSessionDataDelegate
    
    func urlSession(_ session: URLSession,
                    dataTask: URLSessionDataTask,
                    didReceive response: URLResponse,
                    completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        
        completionHandler(.allow)
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        self.data.append(data)
    }
}
