//
//  Protocols.swift
//  WeatherApp
//
//  Created by Jorge Orjuela on 10/18/17.
//

import CoreData.NSManagedObjectContext
import UIKit

typealias OperationCompletionBlock = (([Error]) -> Void)

protocol ConfigurableCell {
    associatedtype Element

    static var identifier: String { get }

    func configure(for element: Element)
}

protocol ContextSetabble: class {
    var context: NSManagedObjectContext! { get set }
}

protocol Datasource: class { }

protocol DataSourceDelegate: class {
    func datasource(_ datasource: Datasource, cellIdentifierForItemAt indexPath: IndexPath) -> String
    func datasourceDidUpdate(_ datasource: Datasource)
}

protocol DataProvider: class {
    associatedtype ResultType: NSFetchRequestResult

    weak var delegate: DataProviderDelegate? { get set }
    var sectionIndexTitlesForTableView: [String]? { get }

    func numberOfSections() -> Int
    func numberOfItems(in section: Int) -> Int
    func object(at indexPath: IndexPath) -> ResultType
    func reconfigureFetchRequest(_ block: (NSFetchRequest<ResultType>) -> Void)
    func title(at section: Int) -> String?
}

protocol DataProviderDelegate: class {
    func dataProviderDidUpdate(updates: [Update])
}

protocol ManagedObjectConvertible: class {
    
    static var entityName: String { get }
    
    static func deleteAll(in context: NSManagedObjectContext,
                          matchingPredicate predicate: NSPredicate?,
                          mergeChanges: Bool)
    
    @discardableResult
    static func findOrCreate(in context: NSManagedObjectContext,
                             matchingPredicate predicate: NSPredicate,
                             configure: (Self) -> Void) -> Self
    
    @discardableResult
    static func findOrFetch(in context: NSManagedObjectContext, matchingPredicate predicate: NSPredicate) -> Self?
    
    @discardableResult
    static func insert(in context: NSManagedObjectContext, configure: (Self) -> Void) -> Self
    
    @discardableResult
    static func insertOrUpdate(inContext context: NSManagedObjectContext, dictionary: JSONDictionary) -> Self?
}

protocol ObservableOperation {
    func operationDidStart(_ operation: WHOperation)
    func operation(_ operation: WHOperation, didProduceOperation newOperation: Operation)
    func operationDidFinish(_ operation: WHOperation, errors: [Error])
}

protocol OperationCondition {
    
    static var name: String { get }
    static var isMutuallyExclusive: Bool { get }
    
    func dependency(for operation: Operation) -> Operation?
    func evaluate(for operation: Operation, completion: @escaping (OperationConditionResult) -> Void)
}

protocol OperationQueueDelegate: NSObjectProtocol {
    func operationQueue(_ operationQueue: WHOperationQueue, willAddOperation operation: Operation)
    func operationQueue(_ operationQueue: WHOperationQueue,
                        operationDidFinish operation: Operation,
                        withErrors errors: [Error])
}

protocol PersistentContainerSettable: class {
    var persistentContainer: NSPersistentContainer! { get set }
}

protocol RemoteSyncronizable: class {

    /// the name for the local id field
    static var localIdKeyName: String { get }

    /// the name for the remote id field
    static var remoteIdKeyName: String { get }
}

protocol ResponseSerializer {
    associatedtype SerializedValue

    func serialize(request: URLRequest?, response: HTTPURLResponse?, data: Data, errors: [Error]) -> Result<SerializedValue>
}

protocol SegueHandlerType {
    associatedtype SegueIdentifier: RawRepresentable
}

protocol StoryboardIdentifiable {
    static var storyboardIdentifier: String { get }
}

protocol StoryboardHandlerType {
    associatedtype StoryboardName: RawRepresentable
}

protocol UserDefaultsStorable {
    func object(forKey defaultName: String) -> Any?
    func removeObject(forKey defaultName: String)
    func set(_ value: Any?, forKey defaultName: String)
}
