//
//  Category.swift
//  WeatherApp
//
//  Created by Jorge Orjuela on 10/18/17.
//

import CoreData.NSManagedObject

private let measurementFormatter: MeasurementFormatter = {
    return MeasurementFormatter()
}()

final class Weather: NSManagedObject {

    @NSManaged private(set) var city: String
    @NSManaged private(set) var country: String
    @NSManaged private(set) var descriptionText: String
    @NSManaged private(set) var humidity: Double
    @NSManaged private var maximunTemperature: Double
    @NSManaged private var minimunTemperature: Double
    @NSManaged private(set) var pressure: Double
    @NSManaged private var temperature: Double

    var readableMinimunTemperature: String {
        let measurement = Measurement(value: temperature, unit: UnitTemperature.fahrenheit)
        return measurementFormatter.string(from: measurement)
    }

    var readableMaximunTemperature: String {
        let measurement = Measurement(value: temperature, unit: UnitTemperature.fahrenheit)
        return measurementFormatter.string(from: measurement)
    }

    var readableTemperature: String {
        let measurement = Measurement(value: temperature, unit: UnitTemperature.fahrenheit)
        return measurementFormatter.string(from: measurement)
    }

    static var sortedFetchRequest: NSFetchRequest<Weather> {
        let request = NSFetchRequest<Weather>(entityName: Weather.entityName)
        request.fetchBatchSize = 20
        request.sortDescriptors = [NSSortDescriptor(key: "city", ascending: true, selector: #selector(NSString.localizedCaseInsensitiveCompare))]
        return request
    }

    // MARK: Static methods

    static func cityPredicate(for city: String) -> NSPredicate {
        return NSPredicate(format: "%K == %@", "city", city.lowercased())
    }

    static func countryPredicate(for country: String) -> NSPredicate {
        return NSPredicate(format: "%K == %@", "country", country.lowercased())
    }
}

extension Weather: ManagedObjectConvertible {

    // Allowable keys for a `Weather`'s dictionary representation.
    public enum DictionaryKey: String {
        case city = "name"
        case country = "sys.country"
        case descriptionText = "weather.description"
        case humidity = "main.humidity"
        case maximunTemperature = "main.temp_min"
        case minimunTemperature = "main.temp_max"
        case pressure = "main.pressure"
        case temperature = "main.temp"
    }

    @discardableResult
    class func insertOrUpdate(inContext context: NSManagedObjectContext, dictionary: JSONDictionary) -> Weather? {
        guard
            /// city
            let city = dictionary[KeyPath(DictionaryKey.city.rawValue)] as? String,

            /// country
            let country = dictionary[KeyPath(DictionaryKey.country.rawValue)] as? String,

            /// humidity
            let humidity = dictionary[KeyPath(DictionaryKey.humidity.rawValue)] as? Double,

            /// maximun temperature
            let maximunTemperature = dictionary[KeyPath(DictionaryKey.maximunTemperature.rawValue)] as? Double,

            /// minimun temperature
            let minimunTemperature = dictionary[KeyPath(DictionaryKey.minimunTemperature.rawValue)] as? Double,

            /// pressure
            let pressure = dictionary[KeyPath(DictionaryKey.pressure.rawValue)] as? Double,

            /// temperature
            let temperature = dictionary[KeyPath(DictionaryKey.temperature.rawValue)] as? Double else {
                print("unable to insert the raw weather \(dictionary)")
                return nil
        }

        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [cityPredicate(for: city), countryPredicate(for: country)])
        return findOrCreate(in: context, matchingPredicate: compoundPredicate) {
            $0.city = city.lowercased()
            $0.country = country.lowercased()
            $0.descriptionText = dictionary[KeyPath(DictionaryKey.descriptionText.rawValue)] as? String ?? ""
            $0.humidity = humidity
            $0.maximunTemperature = maximunTemperature
            $0.minimunTemperature = minimunTemperature
            $0.pressure = pressure
            $0.temperature = temperature
        }
    }
}
