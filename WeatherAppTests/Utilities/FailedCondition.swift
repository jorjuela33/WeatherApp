//
//  FailedCondition.swift
//  WeatherAppTests
//
//  Created by Jorge Orjuela on 10/18/17.
//

import Foundation
@testable import WeatherApp

struct FailedCondition: OperationCondition {
    
    static var name: String = "Failed Condition"
    
    static var isMutuallyExclusive: Bool = false
    
    // MARK: OperationCondition
    
    func dependency(for operation: Operation) -> Operation? {
        return nil
    }
    
    func evaluate(for operation: Operation, completion: @escaping (OperationConditionResult) -> Void) {
        completion(.failed(OperationError.executionFailed))
    }
}
