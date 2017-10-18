//
//  WeatherDetailViewController.swift
//  WeatherApp
//
//  Created by Jorge Orjuela on 10/18/17.
//

import CoreData.NSFetchedResultsController
import CoreLocation.CLLocation
import UIKit

class WeatherDetailViewController: UIViewController {

    private let operationQueue = WHOperationQueue()
    private var fetchedResultsController: NSFetchedResultsController<Weather>?

    @IBOutlet var cityNameLabel: UILabel!
    @IBOutlet var humidityLabel: UILabel!
    @IBOutlet var maximunTemperatureLabel: UILabel!
    @IBOutlet var minimunTemperatureLabel: UILabel!
    @IBOutlet var temperatureLabel: UILabel!

    var persistentContainer: NSPersistentContainer!
    var locationCoordinate: CLLocationCoordinate2D!

    override func viewDidLoad() {
        super.viewDidLoad()
        let location = CLLocation(latitude: locationCoordinate.latitude, longitude: locationCoordinate.longitude)
        let reverseGeocodingOperation = ReverseGeocodingOperation(location: location).operationCompletionBlock { [unowned self] placemark, _ in
            guard
                /// placemark
                let placemark = placemark,

                /// city
                let city = placemark.locality,

                /// isoCountry
                let isoCountryCode = placemark.isoCountryCode else { return }

            self.cityNameLabel.text = city
            self.getWeather(for: city, isoCountryCode: isoCountryCode)
            self.updateViewIfNeeded(city, isoCountryCode: isoCountryCode)
        }

        reverseGeocodingOperation.addObserver(LoadingIndicatorObserver(presentationContext: self))
        operationQueue.addOperation(reverseGeocodingOperation)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: Private methods

    private final func getWeather(for city: String, isoCountryCode: String) {
        let getWeatherOperation = GetWeatherOperation(persistentContainer: self.persistentContainer, city: city, country: isoCountryCode)
        getWeatherOperation.addObserver(LoadingIndicatorObserver(presentationContext: self))
        operationQueue.addOperation(getWeatherOperation)
    }

    private final func updateViewIfNeeded(_ city: String, isoCountryCode: String) {
        let predicates = [Weather.cityPredicate(for: city), Weather.countryPredicate(for: isoCountryCode)]
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)

        guard let weather = Weather.findOrFetch(in: persistentContainer.viewContext, matchingPredicate: compoundPredicate) else { return }

        humidityLabel.text = "Humidity: \(weather.humidity)"
        maximunTemperatureLabel.text = "Maximun Temperature: \(weather.readableMaximunTemperature)"
        minimunTemperatureLabel.text = "Minimun Temperature: \(weather.readableMinimunTemperature)"
        temperatureLabel.text = "\(weather.readableTemperature)"
    }
}

extension WeatherDetailViewController: PersistentContainerSettable, StoryboardIdentifiable {}
