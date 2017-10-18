//
//  SessionManager.swift
//  WeatherApp
//
//  Created by Jorge Orjuela on 10/18/17.
//

import CoreData

final class SessionManager {
    
    /// The session delegate handling all the task and session delegate callbacks.
    weak var delegate: SessionDelegate!
    
    /// The current server used for the manager
    let server: Server
    
    /// The underlying session.
    let session: URLSession
    
    /// A shared instance of the session manager
    static var shared = SessionManager()
    
    // MARK: Initialization
    
    init(configuration: URLSessionConfiguration = URLSessionConfiguration.default,
         delegate: SessionDelegate = SessionDelegate(),
         server: Server = Server.current()) {
        
        self.delegate = delegate
        self.server = server
        self.session = URLSession(configuration: configuration, delegate: delegate, delegateQueue: nil)
    }
    
    deinit {
        session.invalidateAndCancel()
    }
    
    // MARK: Intance methods
    
    func dataRequestOperation(with request: URLRequest) -> URLDataRequestOperation {
        let task = session.dataTask(with: request)
        let dataRequestOperation = URLDataRequestOperation(session: session, task: task)
        delegate[dataRequestOperation.task] = dataRequestOperation
        return dataRequestOperation
    }
}
