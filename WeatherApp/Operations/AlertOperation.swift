//
//  AlertOperation.swift
//  WeatherApp
//
//  Created by Jorge Orjuela on 10/18/17.
//

import UIKit

class AlertOperation: WHOperation {
    
    private let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
    private let presentationContext: UIViewController?
    
    /// If we want to delay the presentation for the alert
    /// we can set this value greater than 0, sometimes
    /// we want to delay the presentation in order to allow
    /// the loading view to hide first
    var delayInterval: TimeInterval = 0
    
    /// The title for the alert controller
    var title: String? {
        get {
            return alertController.title
        }
        
        set {
            alertController.title = newValue
        }
    }
    
    /// The mesage for the alert controller
    var message: String? {
        get {
            return alertController.message
        }
        
        set {
            alertController.message = newValue
        }
    }
    
    // MARK: Initialization
    
    init(presentationContext: UIViewController? = nil, title: String? = nil, message: String? = nil) {
        self.presentationContext = presentationContext ?? UIApplication.shared.keyWindow?.rootViewController
        
        super.init()
        
        self.message = message
        self.title = title
        
        addCondition(MutuallyExclusive<UIViewController>())
        
        name = "Alert Operation"
    }
    
    // MARK: Instance methods
    
    /// Adds a new action to the presentation controller
    ///
    /// title   - The title for the action
    /// style   - The action style
    /// handler - A block to invoke when the actions is performed
    func addAction(_ title: String,
                   style: UIAlertActionStyle = .default,
                   handler: @escaping (AlertOperation) -> Void = { _ in }) {

        let action = UIAlertAction(title: title, style: style) { [unowned self] _ in
            handler(self)
            self.finish()
        }
        
        alertController.addAction(action)
    }
    
    // MARK: Overrided methods
    
    override func execute() {
        guard let presentationContext = presentationContext else {
            finish()
            return
        }
        
        DispatchQueue.main.async {
            if self.alertController.actions.isEmpty {
                self.addAction("OK")
            }

            let delayInterval = Double(Int64(self.delayInterval * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            let dispatchTime = DispatchTime.now() + delayInterval
            DispatchQueue.main.asyncAfter(deadline: dispatchTime, execute: {
                presentationContext.present(self.alertController, animated: true, completion: nil)
            })
        }
    }
}
