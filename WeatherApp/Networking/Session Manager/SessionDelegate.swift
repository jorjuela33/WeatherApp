//
//  SessionDelegate.swift
//  WeatherApp
//
//  Created by Jorge Orjuela on 10/18/17.
//

import Foundation

public final class SessionDelegate: NSObject {
    
    private let lock = NSLock()
    private var operations: [Int: URLRequestOperation] = [:]
    
    subscript(task: URLSessionTask) -> URLRequestOperation? {
        get {
            lock.lock()
            defer { lock.unlock() }
            return operations[task.taskIdentifier]
        }
        
        set {
            lock.lock()
            operations[task.taskIdentifier] = newValue
            lock.unlock()
        }
    }
}

extension SessionDelegate: URLSessionTaskDelegate {
    
    // MARK: URLSessionTaskDelegate
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let operation = self[task] else { return }
        
        operation.urlSession(session, task: task, didCompleteWithError: error)
        self[task] = nil
    }
}

extension SessionDelegate: URLSessionDataDelegate {
    
    // MARK: NSURLSessionDataDelegate
    
    public func urlSession(_ session: URLSession,
                           dataTask: URLSessionDataTask,
                           didReceive response: URLResponse,
                           completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        
        guard let operation = self[dataTask] as? URLDataRequestOperation else { return }
        
        operation.urlSession(session, dataTask: dataTask, didReceive: response, completionHandler: completionHandler)
    }
    
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        guard let operation = self[dataTask] as? URLDataRequestOperation else { return }
        
        operation.urlSession(session, dataTask: dataTask, didReceive: data)
    }
}
