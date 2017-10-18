//
//  LoadingIndicatorObserver.swift
//  WeatherApp
//
//  Created by Jorge Orjuela on 10/18/17.
//

import MBProgressHUD

final class LoadingIndicatorObserver: ObservableOperation {
    
    private var cancelled = false
    private let delay: TimeInterval
    private let loadingView: MBProgressHUD?
    
    // MARK: Initialization
    
    public init(title: String = "Loading...", presentationContext: UIViewController? = nil, delay: TimeInterval = 0) {
        self.delay = delay

        guard let _presentationContext = presentationContext ?? UIApplication.shared.keyWindow?.rootViewController else {
            self.loadingView = nil
            return
        }

        let loadingView = MBProgressHUD(view: _presentationContext.view)
        loadingView.label.text = title
        loadingView.removeFromSuperViewOnHide = true
        self.loadingView = loadingView
        _presentationContext.view.addSubview(loadingView)
    }
    
    // MARK: ObservableOperation
    
    func operationDidStart(_ operation: WHOperation) {
        start()
    }
    
    func operation(_ operation: WHOperation, didProduceOperation newOperation: Operation) { /* No OP */ }
    
    func operationDidFinish(_ operation: WHOperation, errors: [Error]) {
        finish()
    }
    
    // MARK: Private methods
    
    fileprivate final func start() {
        cancelled = false
        DispatchQueue.main.async {
            self.loadingView?.show(animated: true)
        }
    }
    
    fileprivate final func finish() {
        let dispatchTime = DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: dispatchTime, execute: {
            guard self.cancelled == false else { return }
            
            self.cancelled = true
            self.loadingView?.hide(animated: true)
        })
    }
}
