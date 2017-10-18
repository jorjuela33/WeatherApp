//
//  URLRequestOperation.swift
//  WeatherApp
//
//  Created by Jorge Orjuela on 10/18/17.
//

import Foundation

let emptyResponseCodes = [204, 205]

enum URLRequestOperationError: Error {
    case inputDataNil
    case inputDataNilOrZeroLength
    case stringSerializationFailed(encoding: String.Encoding)
    case jsonSerializationFailed(error: Error)
    case unacceptableStatusCode(code: Int)
}

class URLRequestOperation: NSObject {
    
    public typealias URLRequestOperationCompletionBlock = ([Error]) -> Void
    public typealias URLRequestOperationValidationBlock = (URLRequest?, HTTPURLResponse) -> Error?
    
    private let acceptableStatusCodes = Array(200..<300)
    private var finishOperations: [URLRequestOperationCompletionBlock] = []
    private let lock = NSLock()
    private var validations: [() -> Error?] = []
    
    /// The underlying operation queue.
    let operationQueue = OperationQueue()
    
    /// the request for this operation
    var request: URLRequest? {
        return task.originalRequest
    }
    
    /// the response from the host
    var response: HTTPURLResponse? {
        return task.response as? HTTPURLResponse
    }
    
    /// The session belonging to the underlying task.
    let session: URLSession
    
    /// The underlying task.
    let task: URLSessionTask
    
    /// The errors generated throughout the lifecyle of the task.
    private(set) var errors: [Error] = []
    
    // MARK: Initialization
    
    init(session: URLSession, task: URLSessionTask) {
        self.session = session
        self.task = task
        
        super.init()
        
        operationQueue.maxConcurrentOperationCount = 1
        operationQueue.isSuspended = true
    }
    
    // MARK: Instance methods
    
    /// This function is called when the operation completes.
    /// The Operation completionBlock will also be called if both are set.
    /// The block will be invoked in the main thread
    ///
    /// completionHandler -  The block to invoke when the operation finish
    @discardableResult
    func requestCompletionBlock(_ completionHandler: @escaping URLRequestOperationCompletionBlock) -> Self {
        operationQueue.addOperation { completionHandler(self.errors) }
        return self
    }
    
    /// Resume the operation.
    @discardableResult
    public func resume() -> Self {
        if task.state == .completed {
            operationQueue.isSuspended = false
        } else {
            task.resume()
        }
        
        return self
    }
    
    /// Suspend the operation.
    ///
    /// Suspending a task preventing from continuing to
    /// load data.
    @discardableResult
    public func suspend() -> Self {
        operationQueue.isSuspended = true
        if task.state == .running {
            task.suspend()
        }
        
        return self
    }
    
    /// Validates the request, using the specified closure.
    ///
    /// validationBlock - A closure to validate the request.
    @discardableResult
    open func validate(_ validationBlock: @escaping URLRequestOperationValidationBlock) -> Self {
        let _validationBlock: (() -> Error?) = { [unowned self] in
            guard let response = self.response else { return nil }
            
            return validationBlock(self.task.originalRequest, response)
        }
        
        validations.append(_validationBlock)
        return self
    }
    
    /// Validates that the response has a status code in the specified sequence.
    ///
    /// acceptableStatusCodes - The range of acceptable status codes.
    @discardableResult
    open func validate() -> Self {
        return validate(acceptableStatusCodes: acceptableStatusCodes)
    }
    
    /// Validates that the response has a status code in the specified sequence.
    ///
    /// acceptableStatusCodes - The range of acceptable status codes.
    @discardableResult
    open func validate<S: Sequence>(acceptableStatusCodes: S) -> Self where S.Iterator.Element == Int {
        return validate {[unowned self] _, response in
            return self.validate(acceptableStatusCodes: acceptableStatusCodes, response: response)
        }
    }
    
    // MARK: Private methods
    
    private final func executeValidations() {
        for validation in validations {
            guard let error = validation() else { continue }
            
            errors.append(error)
        }
    }
    
    private final func validate<S: Sequence>(acceptableStatusCodes: S,
                                             response: HTTPURLResponse) -> Error? where S.Iterator.Element == Int {
        var error: Error?
        if !acceptableStatusCodes.contains(response.statusCode) {
            error = URLRequestOperationError.unacceptableStatusCode(code: response.statusCode)
        }
        
        return error
    }
}

extension URLRequestOperation: URLSessionTaskDelegate {
    
    // MARK: URLSessionTaskDelegate
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            errors.append(error)
        }
        
        executeValidations()
        operationQueue.isSuspended = false
    }
}
