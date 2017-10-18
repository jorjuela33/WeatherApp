//
//  MutuallyExclusive.swift
//  WeatherApp
//
//  Created by Jorge Orjuela on 10/18/17.
//

import Foundation

struct MutuallyExclusive<T>: OperationCondition {
    
    /// the name for the condition
    static var name: String {
        return "MutuallyExclusive<\(T.self)>"
    }
    
    static var isMutuallyExclusive: Bool {
        return true
    }
    
    // MARK: OperationCondition
    
    func dependency(for operation: Operation) -> Foundation.Operation? {
        return nil
    }
    
    func evaluate(for operation: Operation, completion: @escaping (OperationConditionResult) -> Void) {
        completion(.satisfied)
    }
}

enum Alert { }
typealias AlertPresentation = MutuallyExclusive<Alert>
