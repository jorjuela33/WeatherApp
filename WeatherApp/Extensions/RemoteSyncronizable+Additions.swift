//
//  RemoteSyncronizable+Additions.swift
//  WeatherApp
//
//  Created by Jorge Orjuela on 10/18/17.
//

import CoreData.NSManagedObject

extension RemoteSyncronizable where Self: NSManagedObject {

    static var localIdKeyName: String {
        return "id"
    }

    static var markedForRemoteSyncronizationPredicate: NSPredicate {
        return NSPredicate(format: "%K.length == 0", remoteIdKeyName)
    }

    static var remoteIdKeyName: String {
        return "id"
    }
}
