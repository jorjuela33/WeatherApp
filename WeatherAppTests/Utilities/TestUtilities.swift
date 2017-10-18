//
//  TestUtilities.swift
//  KountyTests
//
//  Created by Jorge Orjuela on 9/15/17.
//  Copyright © 2017 Kounty. All rights reserved.
//

import CoreData.NSPersistentContainer
@testable import Kounty

func createPersistentContainerWithInMemoryStore() -> NSPersistentContainer {
    let persistentContainer = NSPersistentContainer(name: "Kounty")
    let storeDescription = NSPersistentStoreDescription()
    storeDescription.type = NSInMemoryStoreType
    persistentContainer.persistentStoreDescriptions = [storeDescription]
    persistentContainer.loadPersistentStores { _, _ in }
    return persistentContainer
}

extension KountyError {
    
    var isEmptyAuthToken: Bool {
        switch self {
        case .emptyAuthToken: return true
        default: return false
        }
    }
}

extension KountyError.ValidationFailedReason {
    
    var isTakenEmail: Bool {
        switch self {
        case .takenEmail: return true
        default: return false
        }
    }
}

extension ValidationResult {
    
    var isSuccess: Bool {
        switch self {
        case .success: return true
        default: return false
        }
    }
    
    var error: ValidationError? {
        switch self {
        case .success: return nil
        case .failure(let validationError): return validationError
        }
    }
}
