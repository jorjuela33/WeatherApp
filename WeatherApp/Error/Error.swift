//
//  Error.swift
//  WeatherApp
//
//  Created by Jorge Orjuela on 10/18/17.
//

import Foundation

enum WHError: Error {
    case emptyPlacemarks
    case invalidResponseType(reason: String)
    case invalidManagedObjectType
    case unableToStoreManagedObject
    case unReachableNetwork

    var reason: Any? {
        switch self {
        case .invalidResponseType(let reason): return reason
        default: return nil
        }
    }
}
