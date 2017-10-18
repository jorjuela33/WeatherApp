//
//  TableViewArrayDatasource.swift
//  WeatherApp
//
//  Created by Jorge Orjuela on 10/18/17.
//

import UIKit

final class TableViewArrayDatasource <Cell: UITableViewCell, Element>: NSObject, UITableViewDataSource where Cell: ConfigurableCell,
                                                                                                             Cell.Element == Element {
    
    typealias ConfigureCellBlock = ((Cell, Element) -> Void)
    
    private let configureCellBlock: ConfigureCellBlock?
    private weak var delegate: DataSourceDelegate!
    private var items = [Element]() {
        didSet {
            tableView.reloadData()
        }
    }
    private let tableView: UITableView
    
    var commitEditingStyleClosure: ((UITableView, UITableViewCellEditingStyle, IndexPath) -> Void)?
    
    // MARK: Initialization
    
    init(tableView: UITableView, items: [Element], delegate: DataSourceDelegate, configureCellBlock: ConfigureCellBlock? = nil) {
        self.configureCellBlock = configureCellBlock
        self.delegate = delegate
        self.items = items
        self.tableView = tableView
        
        super.init()
        
        self.tableView.dataSource = self
    }
    
    // MARK: Instance mehtods
    
    /// returns the element at the given indexPath
    final func object(at indexPath: IndexPath) -> Element {
        return items[indexPath.row]
    }
    
    /// updates the datasource with the new given elements
    final func update(_ items: [Element]) {
        self.items = items
    }
    
    // MARK: UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = delegate.datasource(self, cellIdentifierForItemAt: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        if let cell = cell as? Cell {
            let element = items[indexPath.row]
            cell.configure(for: element)
            configureCellBlock?(cell, element)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return commitEditingStyleClosure != nil
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        commitEditingStyleClosure?(tableView, editingStyle, indexPath)
    }
}

extension TableViewArrayDatasource: Datasource {}
