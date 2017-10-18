//
//  ReverseGeocodingOperation.swift
//  WeatherApp
//
//  Created by Jorge Orjuela on 10/18/17.
//

import CoreLocation.CLLocation

final class ReverseGeocodingOperation: WHOperation {

    private var internalErrors: [Error] = []
    private let location: CLLocation
    private var placemark: CLPlacemark?
    private let operationQueue = WHOperationQueue()

    // MARK: Initialization

    init(location: CLLocation) {
        self.location = location
        operationQueue.isSuspended = true

        super.init()

        self.name = "Reverse Geocoding Operation"
    }

    // MARK: Instance methods

    @discardableResult
    final func operationCompletionBlock(_ completionBlock: @escaping ((CLPlacemark?, [Error]) -> Void)) -> Self {
        operationQueue.addOperation {
            DispatchQueue.main.async {
                completionBlock(self.placemark, self.internalErrors)
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
        CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
            if let error = error {
                self.finishWithError(error)
            } else if let placemark = placemarks?.first {
                self.placemark = placemark
                self.finish()
            } else {
                self.finishWithError(WHError.emptyPlacemarks)
            }
        }
    }

    // MARK: Private methods

    private final func produceAlertOperation() {
        let alertOperation = AlertOperation(title: "Attention!", message: "Unable to perform the reverse geocoding")
        produceOperation(alertOperation)
    }
}
