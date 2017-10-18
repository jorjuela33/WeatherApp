//
//  BlockObserver.swift
//  WeatherApp
//
//  Created by Jorge Orjuela on 10/18/17.
//

import Foundation

struct BlockObserver: ObservableOperation {
    
    private let startHandler: ((WHOperation) -> Void)?
    private let produceHandler: ((WHOperation, Operation) -> Void)?
    private let finishHandler: ((WHOperation, [Error]) -> Void)?
    
    init(
        startHandler: ((WHOperation) -> Void)? = nil,
        produceHandler: ((WHOperation, Operation) -> Void)? = nil,
        finishHandler: ((WHOperation, [Error]) -> Void)? = nil) {
        
        self.startHandler = startHandler
        self.produceHandler = produceHandler
        self.finishHandler = finishHandler
    }
    
    // MARK: ObservableOperation
    
    func operationDidStart(_ operation: WHOperation) {
        startHandler?(operation)
    }
    
    func operation(_ operation: WHOperation, didProduceOperation newOperation: Operation) {
        produceHandler?(operation, newOperation)
    }
    
    func operationDidFinish(_ operation: WHOperation, errors: [Error]) {
        finishHandler?(operation, errors)
    }
}
