//
//  FetchedResultsDataProvider.swift
//  WeatherApp
//
//  Created by Jorge Orjuela on 10/18/17.
//

import CoreData.NSManagedObjectContext

enum Update {
    case insert(IndexPath)
    case update(IndexPath)
    case move(IndexPath, IndexPath)
    case delete(IndexPath)
}

final class FetchedResultsDataProvider<ResultType: NSFetchRequestResult>: NSObject, NSFetchedResultsControllerDelegate {
    
    fileprivate let fetchedResultsController: NSFetchedResultsController<ResultType>
    private var updates: [Update] = []
    
    weak var delegate: DataProviderDelegate?
    
    /// the underliying fetch request 
    var fetchRequest: NSFetchRequest<ResultType> {
        return fetchedResultsController.fetchRequest
    }
    
    /// the fetched objects from core data
    var fetchedObjects: [ResultType]? {
        return fetchedResultsController.fetchedObjects
    }
    
    var sectionIndexTitlesForTableView: [String]? {
        return fetchedResultsController.sectionIndexTitles
    }
    
    // MARK: Initialization
    
    init(fetchedResultsController: NSFetchedResultsController<ResultType>) {
        self.fetchedResultsController = fetchedResultsController
        
        super.init()
        
        self.fetchedResultsController.delegate = self
        try? self.fetchedResultsController.performFetch()
    }
    
    // MARK: Instance methods
    
    func indexOf(_ object: ResultType) -> IndexPath? {
        return fetchedResultsController.indexPath(forObject: object)
    }
    
    // MARK: NSFetchedResultsControllerDelegate
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        updates = []
    }
    
    @objc(controller:didChangeObject:atIndexPath:forChangeType:newIndexPath:)
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            guard let indexPath = newIndexPath else { fatalError("Index path should be not nil") }
            updates.append(.insert(indexPath))
            
        case .update:
            guard let indexPath = indexPath else { fatalError("Index path should be not nil") }
            updates.append(.update(indexPath))
            
        case .move:
            guard let indexPath = indexPath else { fatalError("Index path should be not nil") }
            guard let newIndexPath = newIndexPath else { fatalError("New index path should be not nil") }
            updates.append(.move(indexPath, newIndexPath))
            
        case .delete:
            guard let indexPath = indexPath else { fatalError("Index path should be not nil") }
            updates.append(.delete(indexPath))
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.dataProviderDidUpdate(updates: updates)
    }
}

extension FetchedResultsDataProvider: DataProvider {
    
    // MARK: DataProvider
    
    func numberOfSections() -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    func numberOfItems(in section: Int) -> Int {
        guard fetchedResultsController.sections?.isEmpty == false else { return 0 }
        
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func object(at indexPath: IndexPath) -> ResultType {
        return fetchedResultsController.object(at: indexPath)
    }
    
    func reconfigureFetchRequest(_ block: (NSFetchRequest<ResultType>) -> Void) {
        NSFetchedResultsController<ResultType>.deleteCache(withName: fetchedResultsController.cacheName)
        block(fetchedResultsController.fetchRequest)
        try? fetchedResultsController.performFetch()
        delegate?.dataProviderDidUpdate(updates: [])
    }
    
    func title(at section: Int) -> String? {
        return section < fetchedResultsController.sectionIndexTitles.count ? fetchedResultsController.sectionIndexTitles[section] : nil
    }
}
