//
//  GetWeatherOperation.swift
//  WeatherApp
//
//  Created by Jorge Orjuela on 10/18/17.
//

import CoreData.NSManagedObjectContext

private let apiKey = "dd7e6b1486fbc212c84c4d87782dd030"

final class GetWeatherOperation: WHOperation {

    private var internalErrors: [Error] = []
    private let operationQueue = WHOperationQueue()
    private let persistentContainer: NSPersistentContainer
    
    /// The underlying data request operation
    let dataRequestOperation: URLDataRequestOperation
    
    // MARK: Initialization
    
    init(persistentContainer: NSPersistentContainer,
         city: String,
         country: String,      
         currentServer: Server = Server.current(),
         sessionManager: SessionManager = SessionManager.shared) {

        guard let url = currentServer.apiEndPoint?.appendingPathComponent("weather") else { fatalError("Empty server endpoint") }

        let parameters = ["q": "\(city),\(country)", "APPID": apiKey]
        let request = ParameterEncoding.url.encode(URLRequest(url: url, method: .GET), parameters: parameters).0
        dataRequestOperation = sessionManager.dataRequestOperation(with: request)

        self.persistentContainer = persistentContainer
        operationQueue.isSuspended = true
        
        super.init()

        addCondition(ReachabilityCondition(host: url))
        self.name = "Get Weather Operation"
    }
    
    // MARK: Instance methods
    
    @discardableResult
    final func operationCompletionBlock(_ completionBlock: @escaping OperationCompletionBlock) -> Self {
        operationQueue.addOperation {
            DispatchQueue.main.async {
                completionBlock(self.internalErrors)
            }
        }
        
        return self
    }
    
    // MARK: Overrided methods
    
    override func finished(_ errors: [Error]) {
        if !errors.isEmpty { produceAlertOperation() }
        self.internalErrors = errors
        operationQueue.isSuspended = false
    }
    
    override func execute() {
        dataRequestOperation.responseJSON { [unowned self] result in
            guard let response = result.value else {
                self.finishWithError(result.error)
                return
            }

            guard let JSONRecord = response as? JSONDictionary else {
                self.finishWithError(WHError.invalidResponseType(reason: "Expected type JSONDictionary got \(type(of: response))"))
                return
            }

            self.persistentContainer.performBackgroundTask { context in
                guard Weather.insertOrUpdate(inContext: context, dictionary: JSONRecord) != nil else {
                    self.finishWithError(WHError.unableToStoreManagedObject)
                    return
                }

                do {
                    try context.save()
                    self.finish()
                } catch {
                    self.finishWithError(error)
                }
            }
        }
        .validate(acceptableStatusCodes: [200])
        dataRequestOperation.resume()
    }
    
    // MARK: Private methods

    private final func produceAlertOperation() {
        var message = "Unable to fetch the weather information."

        if let error = internalErrors.first as? WHError {
            switch error {
            case .unReachableNetwork: message = "There is no network connection. Connect to Wi-Fi or move to service coverage area."
            default: break
            }
        }
        
        let alertOperation = AlertOperation(title: "Attention!", message: message)
        produceOperation(alertOperation)
    }
}
