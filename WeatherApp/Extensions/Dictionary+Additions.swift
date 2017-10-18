//
//  Dictionary+Additions.swift
//  WeatherApp
//
//  Created by Jorge Orjuela on 10/18/17.
//

import Foundation

struct KeyPath {

    private var keys: [String]

    /// true if there is no remaining keys
    var isEmpty: Bool {
        return keys.isEmpty
    }

    /// the full path
    var path: String {
        return keys.joined(separator: ".")
    }

    // MARK: Instance methods
    
    func headAndTail() -> (head: String, tail: KeyPath)? {
        guard keys.isEmpty == false else { return nil }
        
        var tail = keys
        let head = tail.removeFirst()
        return (head, KeyPath(keys: tail))
    }
}

extension KeyPath {
    init(_ string: String) {
        keys = string.components(separatedBy: ".")
    }
}

extension Dictionary where Key == String {
    
    subscript(keyPath: KeyPath) -> Any? {
        get {
            switch keyPath.headAndTail() {
            case let (head, tail)? where tail.isEmpty:
                return self[head]

            case let (head, tail)?:
                switch self[head] {
                case let nestedDict as [Key: Any]:
                    return nestedDict[tail]
                    
                default:
                    return nil
                }
                
            default:
                return nil
            }
        }

        set {
            switch keyPath.headAndTail() {
            case let (head, tail)? where tail.isEmpty:
                return self[head] = newValue as? Value
                
            case let (head, tail)?:
                let value = self[head]

                switch value {
                case var nestedDict as [Key: Any]:
                    nestedDict[tail] = newValue
                    self[head] = nestedDict as? Value
                    
                default:
                    break
                }
                
            default:
                break
            }
        }
    }
}
