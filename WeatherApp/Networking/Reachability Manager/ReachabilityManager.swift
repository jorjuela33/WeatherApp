//
//  ReachabilityManager.swift
//  WeatherApp
//
//  Created by Jorge Orjuela on 10/18/17.
//

import Foundation.NSURL
import SystemConfiguration

enum ReachabilityError: Error {
    case failedToCreateWithAddress(sockaddr_in)
    case failedToCreateWithHostname(String)
    case failedToMonitorWithHostName(String)
}

protocol NetworkObservable: class {
    func reachabilityManager(manager: ReachabilityManager, didChangeToNetworkStatus status: ReachabilityManager.ReachabilityStatus)
}

protocol NetworkReachable {
    var status: ReachabilityManager.ReachabilityStatus { get }
}

class ReachabilityManager {

    private static var reachabilityRefs = [String: SCNetworkReachability]()
    private let host: String
    private let lock = NSLock()
    private var observers: [NetworkObservable] = []
    private var _status: ReachabilityStatus =  .unknown

    var status: ReachabilityStatus {
        return _status
    }

    enum ReachabilityStatus {
        case notReachable, reachableViaWiFi, reachableViaWWAN, unknown
    }

    // MARK: Initialization

    init(reference: SCNetworkReachability, host: String = "_defaultReferenceKey") {
        self.host = host
        var reachabilityFlags: SCNetworkReachabilityFlags = []
        if SCNetworkReachabilityGetFlags(reference, &reachabilityFlags) {
            if reachabilityFlags.contains(.reachable) {
                _status = reachabilityFlags.contains(.isWWAN) == false ? .reachableViaWiFi : .reachableViaWWAN
            } else {
                _status = .notReachable
            }
        }

        if ReachabilityManager.reachabilityRefs.keys.contains(host) == false {
            ReachabilityManager.reachabilityRefs[host] = reference
        }
    }

    public convenience init(host: String) throws {
        guard
            /// c string
            let hostCString = host.cString(using: String.Encoding.utf8),

            /// reachability ref
            let ref = ReachabilityManager.reachabilityRefs[host] ?? SCNetworkReachabilityCreateWithName(nil, hostCString) else {

                throw ReachabilityError.failedToCreateWithHostname(host)
        }

        self.init(reference: ref, host: host)
    }

    deinit {
        stopMonitoring()
    }

    // MARK: Instance methods

    /// append a new observer for the current instance of the reachability
    func addObserver(_ observer: NetworkObservable) {
        lock.lock()
        observers.append(observer)
        lock.unlock()
    }

    /// remove the observer for the current instance of the reachability
    func removeObserver(_ observer: NetworkObservable) {
        lock.lock()
        defer { lock.unlock() }

        guard let index = self.observers.index(where: { $0 === observer }) else { return }

        observers.remove(at: index)

    }

    /// Starts monitoring for changes in network reachability status.
    func startMonitoring() throws {
        guard let reference = ReachabilityManager.reachabilityRefs[host] else {
            return
        }

        var context = SCNetworkReachabilityContext(version: 0, info: nil, retain: nil, release: nil, copyDescription: nil)
        context.info = Unmanaged.passRetained(self).toOpaque()
        let callback = SCNetworkReachabilitySetCallback(reference, { _, reachabilityFlags, info in
            var status: ReachabilityStatus = .notReachable

            if reachabilityFlags.contains(.reachable) {
                status = reachabilityFlags.contains(.isWWAN) == false ? .reachableViaWiFi : .reachableViaWWAN
            }

            guard let info = info else { return }

            let reachability = Unmanaged<ReachabilityManager>.fromOpaque(info).takeUnretainedValue()
            reachability.notifyObservers(status)

        }, &context)

        guard SCNetworkReachabilitySetDispatchQueue(reference, DispatchQueue.main) && callback else {
            throw ReachabilityError.failedToMonitorWithHostName(host)
        }
    }

    /// Stops monitoring for changes in network reachability status.
    func stopMonitoring() {
        guard let reference = ReachabilityManager.reachabilityRefs[host] else { return }

        SCNetworkReachabilitySetCallback(reference, nil, nil)
        SCNetworkReachabilitySetDispatchQueue(reference, nil)
    }

    // MARK: Private methods

    private final func notifyObservers(_ status: ReachabilityStatus) {
        guard _status != status else { return }

        _status = status
        for observer in observers {
            observer.reachabilityManager(manager: self, didChangeToNetworkStatus: status)
        }
    }

    // MARK: Static methods

    static func reachabilityForInternetConnection() throws -> ReachabilityManager {
        var address = sockaddr_in()
        address.sin_len = UInt8(MemoryLayout.size(ofValue: address))
        address.sin_family = sa_family_t(AF_INET)

        guard let reference = withUnsafePointer(to: &address, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else { throw ReachabilityError.failedToCreateWithAddress(address) }

        return ReachabilityManager(reference: reference)
    }

    /// Naive implementation of the reachability, Handle VPN, cellular connection.
    static func requestReachability(_ url: URL, completionHandler: (Bool) -> Void) {
        guard let host = url.host else {
            completionHandler(false)
            return
        }

        do {
            let reachabilityManager = try ReachabilityManager(host: host)
            completionHandler(reachabilityManager.status != .notReachable)
        } catch {
            completionHandler(false)
        }
    }
}

extension ReachabilityManager: NetworkReachable {}
