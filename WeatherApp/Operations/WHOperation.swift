//
//  WHOperation.swift
//  WeatherApp
//
//  Created by Jorge Orjuela on 10/18/17.
//

import Foundation

let operationConditionKey = "com.rave.operationConditionKey"
let operationErrorDomainCode = "com.rave.domain.error"

enum OperationConditionResult {
    case satisfied
    case failed(Error)
    
    var error: Error? {
        switch self {
        case .failed(let error):
            return error
            
        default:
            return nil
        }
    }
}

enum OperationError: Error {
    case conditionFailed
    case executionFailed
}

class WHOperation: Operation {
    
    fileprivate enum State: Int, Comparable {
        /// The initial state of an `Operation`.
        case initialized
        
        /// The `Operation` is ready to begin evaluating conditions.
        case pending
        
        /// The `Operation` is evaluating conditions.
        case evaluatingConditions
        
        /// The `Operation`'s conditions have all been satisfied,
        /// and it is ready to execute.
        case ready
        
        /// The `Operation` is executing.
        case executing
        
        /// Execution of the `Operation` has finished, but it has not yet notified
        /// the queue of this.
        case finishing
        
        /// The `Operation` has finished executing.
        case finished
        
        func canTransitionToState(_ target: State) -> Bool {
            switch (self, target) {
            case (.initialized, .pending):
                return true
            case (.pending, .evaluatingConditions):
                return true
            case (.evaluatingConditions, .ready):
                return true
            case (.ready, .executing):
                return true
            case (.ready, .finishing):
                return true
            case (.executing, .finishing):
                return true
            case (.finishing, .finished):
                return true
            case (.pending, .finishing):
                return true
            default:
                return false
            }
        }
    }
    
    private var hasFinishedAlready = false
    private var internalErrors: [Error] = []
    private var lock = NSLock()
    private var _state: State = .initialized
    
    private var state: State {
        get {
            lock.lock()
            defer { lock.unlock() }
            return _state
        }
        
        set(newState) {
            assert(_state.canTransitionToState(newState))
            
            guard _state != .finished else { return }
            
            willChangeValue(forKey: "state")
            lock.lock()
            _state = newState
            lock.unlock()
            didChangeValue(forKey: "state")
        }
    }
    
    /// The conditions for this operation
    private(set) var conditions: [OperationCondition] = []
    
    /// The observers of the operation
    private var observers = [ObservableOperation]()
    
    override open var isAsynchronous: Bool {
        return true
    }
    
    /// Wheter the resquest is user initiated or not
    public var userInitiated: Bool {
        get {
            return qualityOfService == .userInitiated
        }
        
        set {
            assert(state < .executing)
            
            qualityOfService = newValue ? .userInitiated : .default
        }
    }
    
    override open var isExecuting: Bool {
        return state == .executing
    }
    
    override open var isFinished: Bool {
        return state == .finished
    }
    
    override open var isReady: Bool {
        switch state {
        case .initialized:
            return isCancelled
            
        case .pending:
            guard !isCancelled else {
                return true
            }
            
            if super.isReady {
                evaluateConditions()
            }
            
            return false
        case .ready:
            return super.isReady || isCancelled
            
        default:
            return false
        }
    }
    
    // MARK: Intance methods
    
    /// Adds a new condition for this operation
    final func addCondition(_ operationCondition: OperationCondition) {
        assert(state < .evaluatingConditions)
        
        conditions.append(operationCondition)
    }
    
    /// Adds a new observer for the operation
    func addObserver(_ observer: ObservableOperation) {
        assert(state < .executing)
        
        observers.append(observer)
    }
    
    /// Cancels the current request
    ///
    /// error - The error produced by the request
    final func cancelWithError(_ error: Error) {
        internalErrors.append(error)
        cancel()
    }
    
    /// The entry point of all operations
    func execute() {
        finish()
    }
    
    /// Finish the current request
    ///
    /// errors - Optional value containing the errors
    ///          produced by the operation
    func finish(_ errors: [Error] = []) {
        guard hasFinishedAlready == false else { return }
        
        let combinedErrors = internalErrors + errors
        hasFinishedAlready = true
        state = .finishing
        finished(combinedErrors)
        
        for observer in observers {
            observer.operationDidFinish(self, errors: combinedErrors)
        }
        
        observers.removeAll()
        state = .finished
    }
    
    /// Should be overriden for the child operations
    func finished(_ errors: [Error]) {
        // No op.
    }
    
    /// Finish the current request
    ///
    /// error - The error produced by the request
    final func finishWithError(_ error: Error?) {
        guard let error = error else {
            finish()
            return
        }
        
        finish([error])
    }
    
    /// Notify to the observer when a suboperation is created for this operation
    final func produceOperation(_ operation: Operation) {
        for observer in observers {
            observer.operation(self, didProduceOperation: operation)
        }
    }
    
    /// Indicates that the Operation can now begin to evaluate readiness conditions,
    /// if appropriate.
    func willEnqueue() {
        state = .pending
    }
    
    // MARK: KVO methods
    
    @objc
    class func keyPathsForValuesAffectingIsReady() -> Set<NSObject> {
        return ["state" as NSObject]
    }
    
    @objc
    class func keyPathsForValuesAffectingIsExecuting() -> Set<NSObject> {
        return ["state" as NSObject]
    }
    
    @objc
    class func keyPathsForValuesAffectingIsFinished() -> Set<NSObject> {
        return ["state" as NSObject]
    }
    
    // MARK: Overrided methods
    
    override final func main() {
        assert(state == .ready)
        
        guard isCancelled == false && internalErrors.isEmpty else {
            finish()
            return
        }
        
        state = .executing
        
        for observer in observers {
            observer.operationDidStart(self)
        }
        
        execute()
    }
    
    override func start() {
        super.start()
        if isCancelled {
            finish()
        }
    }
    
    // MARK: Private methods
    
    private func evaluateConditions() {
        assert(state == .pending && !isCancelled)
        
        state = .evaluatingConditions
        
        let conditionGroup = DispatchGroup()
        var results = [OperationConditionResult?](repeating: nil, count: conditions.count)
        
        for (index, condition) in conditions.enumerated() {
            conditionGroup.enter()
            condition.evaluate(for: self) { result in
                results[index] = result
                conditionGroup.leave()
            }
        }
        
        conditionGroup.notify(queue: DispatchQueue.global(qos: DispatchQoS.QoSClass.default)) {
            self.internalErrors += results.flatMap { $0?.error }
            
            if self.isCancelled {
                self.internalErrors.append(OperationError.conditionFailed)
            }
            
            self.state = .ready
        }
    }
}

private func < (lhs: WHOperation.State, rhs: WHOperation.State) -> Bool {
    return lhs.rawValue < rhs.rawValue
}

private func == (lhs: WHOperation.State, rhs: WHOperation.State) -> Bool {
    return lhs.rawValue == rhs.rawValue
}
