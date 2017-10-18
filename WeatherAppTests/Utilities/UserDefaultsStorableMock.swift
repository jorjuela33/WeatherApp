//
//  UserDefaultsStorableMock.swift
//  WeatherAppTests
//
//  Created by Jorge Orjuela on 10/18/17.
//

import Foundation
@testable import WeatherApp

class UserDefaultsStorableMock: UserDefaultsStorable {

    private var value: Any?

    // MARK: Initialization

    init(value: String? = nil) {
        self.value = value
    }

    // MARK: UserDefaultsStorable

    func object(forKey defaultName: String) -> Any? {
        return value
    }

    func removeObject(forKey defaultName: String) {
        value = nil
    }

    func set(_ value: Any?, forKey defaultName: String) {
        self.value = value
    }
}

