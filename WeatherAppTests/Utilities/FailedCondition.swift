//
//  FailedCondition.swift
//  KountyTests
//
//  Created by Jorge Orjuela on 9/15/17.
//  Copyright © 2017 Kounty. All rights reserved.
//

import Foundation
@testable import Kounty

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
