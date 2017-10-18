//
//  NSManagedObjectContext+Additions.swift
//  WeatherApp
//
//  Created by Jorge Orjuela on 10/18/17.
//

import CoreData.NSManagedObjectContext

extension NSManagedObjectContext {
    
    /// creates a background context to perform a task
    final func createBackgroundContext() -> NSManagedObjectContext {
        let internalContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        internalContext.persistentStoreCoordinator = persistentStoreCoordinator
        internalContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return internalContext
    }
    
    /// Inserts a new object in the current context
    ///
    /// Element - The core data model to insert
    final func insertObject<Element: NSManagedObject>() -> Element where Element: ManagedObjectConvertible {
        let entityName = String(describing: Element.self)
        let newObject = NSEntityDescription.insertNewObject(forEntityName: entityName, into: self) as? Element

        guard let object = newObject else { fatalError("Wrong object type") }
        
        return object
    }
}
