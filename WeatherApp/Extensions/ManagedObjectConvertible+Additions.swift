//
//  ManagedObjectConvertible+Additions.swift
//  WeatherApp
//
//  Created by Jorge Orjuela on 10/18/17.
//

import CoreData.NSManagedObject

extension ManagedObjectConvertible where Self: NSManagedObject {
    
    static var entityName: String {
        return String(describing: self).capitalized
    }
    
    /// Delete all the objects from the entity, if saveChanges == true then the context
    /// will sync the changes inmediately, if saveChanged == false then the operation
    /// should sync the context
    static func deleteAll(in context: NSManagedObjectContext,
                          matchingPredicate predicate: NSPredicate?, mergeChanges: Bool) {
        do {
            let fetchRequest = self.fetchRequest()
            fetchRequest.predicate = predicate
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            try context.execute(deleteRequest)
            
            guard mergeChanges else { return }
            
            try context.save()
        } catch {
            print("Unable to delete the objects for the entity \(type(of: self)), error: \(error)")
        }
    }
    
    /// Find/Create the object in core data
    static func findOrCreate(in context: NSManagedObjectContext,
                             matchingPredicate predicate: NSPredicate, configure: (Self) -> Void) -> Self {
        let object = fetch(in: context) { fetchRequest in
            fetchRequest.predicate = predicate
            fetchRequest.returnsObjectsAsFaults = false
            fetchRequest.fetchLimit = 1
        }
        
        guard let existingObject = object.first else {
            let newObject: Self = context.insertObject()
            configure(newObject)
            return newObject
        }
        
        configure(existingObject)
        return existingObject
    }
    
    /// Finds the first ocurrence of the object
    static func findOrFetch(in context: NSManagedObjectContext, matchingPredicate predicate: NSPredicate) -> Self? {
        var materializedObject: Self?
        
        context.performAndWait {
            if let object = self.materializedObject(in: context, matchingPredicate: predicate) {
                materializedObject = object
            } else {
                materializedObject = fetch(in: context) { request in
                    request.predicate = predicate
                    request.returnsObjectsAsFaults = false
                    request.fetchLimit = 1
                }.first
            }
        }
        
        return materializedObject
    }
    
    /// Fetch the object with the configured request
    static func fetch(in context: NSManagedObjectContext,
                      configurationBlock: (NSFetchRequest<Self>) -> Void = { _ in }) -> [Self] {
        
        let request = NSFetchRequest<Self>(entityName: String(describing: self))
        configurationBlock(request)
        var results: [Self] = []
        
        context.performAndWait {
            do {
                results = try context.fetch(request)
            } catch {
                print("unable to fetch the objects \(error)")
            }
        }
        
        return results
    }
    
    /// Inserts a new model in the given context
    static func insert(in context: NSManagedObjectContext, configure: (Self) -> Void) -> Self {
        let newObject: Self = context.insertObject()
        configure(newObject)
        return newObject
    }
    
    /// returns the materialized object if exists
    static func materializedObject(in context: NSManagedObjectContext,
                                   matchingPredicate predicate: NSPredicate) -> Self? {
        for obj in context.registeredObjects where !obj.isFault && !obj.isDeleted {
            guard let res = obj as? Self , predicate.evaluate(with: res) else { continue }
            return res
        }
        return nil
    }
}
