//
//  TableViewDatasource.swift
//  WeatherApp
//
//  Created by Jorge Orjuela on 10/18/17.
//

import UIKit

final class TableViewDatasource <Provider: DataProvider, Cell: UITableViewCell>: NSObject, UITableViewDataSource
                                                                                            where Provider.ResultType == Cell.Element,
                                                                                                  Cell: ConfigurableCell {
    
    typealias Element = Provider.ResultType
    
    private let configuationBlock: ((Cell, Element) -> Void)?
    private weak var delegate: DataSourceDelegate!
    private let fetchedResultsDataProvider: Provider
    private let tableView: UITableView
    
    // MARK: Initialization
    
    init(tableView: UITableView,
         fetchedResultsDataProvider: Provider,
         delegate: DataSourceDelegate, configuationBlock: ((Cell, Element) -> Void)? = nil) {
        
        self.fetchedResultsDataProvider = fetchedResultsDataProvider
        self.configuationBlock = configuationBlock
        self.delegate = delegate
        self.tableView = tableView
        
        super.init()
        
        self.fetchedResultsDataProvider.delegate = self
        self.tableView.dataSource = self
        self.tableView.reloadData()
    }
    
    // MARK: Instance methods
    
    func processUpdates(_ updates: [Update]?) {
        defer {
            delegate.datasourceDidUpdate(self)
        }
        
        guard let updates = updates , updates.isEmpty == false else {
            tableView.reloadData()
            return
        }
        
        tableView.beginUpdates()
        
        for update in updates {
            switch update {
            case .insert(let indexPath):
                tableView.insertRows(at: [indexPath], with: .fade)
                
            case let .move(indexPath, newIndexPath):
                tableView.deleteRows(at: [indexPath], with: .fade)
                tableView.insertRows(at: [newIndexPath], with: .fade)
                
            case .delete(let indexPath):
                tableView.deleteRows(at: [indexPath], with: .fade)
                
            case .update(let indexPath):
                tableView.reloadRows(at: [indexPath], with: .none)
            }
        }
        
        tableView.endUpdates()
    }
    
    // MARK: UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsDataProvider.numberOfSections()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsDataProvider.numberOfItems(in: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let element = fetchedResultsDataProvider.object(at: indexPath)
        let identifier = delegate.datasource(self, cellIdentifierForItemAt: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        if let cell = cell as? Cell {
            cell.configure(for: element)
            configuationBlock?(cell, element)
        }
        
        return cell
    }
}

extension TableViewDatasource: DataProviderDelegate {
    
    // MARK: DataProviderDelegate
    
    func dataProviderDidUpdate(updates: [Update]) {
        self.processUpdates(updates)
    }
}

extension TableViewDatasource: Datasource {}
