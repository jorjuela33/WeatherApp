//
//  ReachabilityCondition.swift
//  WeatherApp
//
//  Created by Jorge Orjuela on 10/18/17.
//

import Foundation

struct ReachabilityCondition: OperationCondition {

    static let isMutuallyExclusive = false
    static let hostKey = "Host"
    static let name = "Reachability"

    let host: URL

    init(host: URL? = Server.current().url) {
        guard let url = host else { fatalError("The server url should not be nil") }

        self.host = url
    }

    // MARK: OperationCondition

    func dependency(for operation: Operation) -> Operation? {
        return nil
    }

    func evaluate(for operation: Operation, completion: @escaping (OperationConditionResult) -> Void) {
        ReachabilityManager.requestReachability(host) { reachable in
            guard reachable else {
                completion(.failed(WHError.unReachableNetwork))
                return
            }

            completion(.satisfied)
        }
    }
}
