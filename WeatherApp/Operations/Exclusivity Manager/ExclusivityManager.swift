//
//  ExclusivityManager.swift
//  WeatherApp
//
//  Created by Jorge Orjuela on 10/18/17.
//

import Foundation

class ExclusivityManager {
    
    private let queue = DispatchQueue(label: "com.ravekit.ExclusivityManager")
    private var operations: [String: [WHOperation]] = [:]
    
    /// a shared instance of the controller
    static let shared = ExclusivityManager()
    
    // MARK: Initialization
    
    private init() {}
    
    // MARK: Instance methods
    
    /// Registers an operation as being mutually exclusive
    func add(_ operation: WHOperation, categories: [String]) {
        queue.sync {
            for category in categories {
                var operationsWithThisCategory = operations[category] ?? []
                if let last = operationsWithThisCategory.last {
                    operation.addDependency(last)
                }
                
                operationsWithThisCategory.append(operation)
                operations[category] = operationsWithThisCategory
            }
        }
    }
    
    /// Unregisters an operation from being mutually exclusive.
    func removeOperation(operation: WHOperation, categories: [String]) {
        queue.async {
            for category in categories {
                let matchingOperations = self.operations[category]
                
                if
                    /// the  operations category
                    var operationsWithThisCategory = matchingOperations,
                    
                    /// the index for the operation
                    let index = operationsWithThisCategory.index(of: operation) {
                    
                    operationsWithThisCategory.remove(at: index)
                    self.operations[category] = operationsWithThisCategory
                }
            }
        }
    }
}
