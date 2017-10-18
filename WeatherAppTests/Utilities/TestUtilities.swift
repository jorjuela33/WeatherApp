//
//  TestUtilities.swift
//  WeatherAppTests
//
//  Created by Jorge Orjuela on 10/18/17.
//

import CoreData.NSPersistentContainer
@testable import WeatherApp

func createPersistentContainerWithInMemoryStore() -> NSPersistentContainer {
    let persistentContainer = NSPersistentContainer(name: "WeatherApp")
    let storeDescription = NSPersistentStoreDescription()
    storeDescription.type = NSInMemoryStoreType
    persistentContainer.persistentStoreDescriptions = [storeDescription]
    persistentContainer.loadPersistentStores { _, _ in }
    return persistentContainer
}
