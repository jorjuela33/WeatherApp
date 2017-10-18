//
//  SigninOperationTests.swift
//  KountyTests
//
//  Created by Jorge Orjuela on 9/15/17.
//  Copyright © 2017 Kounty. All rights reserved.
//

import CoreData.NSPersistentContainer
import OHHTTPStubs
import XCTest
@testable import Kounty

class SigninOperationTests: KountyBaseTests {
    
    private let operationQueue = KNOperationQueue()
    private var persistentContainer: NSPersistentContainer!
    
    override func setUp() {
        super.setUp()
        persistentContainer = createPersistentContainerWithInMemoryStore()
    }
    
    override func tearDown() {
        persistentContainer = nil
        OHHTTPStubs.removeAllStubs()
        super.tearDown()
    }
    
    // MARK: Tests
    
    func testThatSigninOperationInitialization() {
        /// Given
        let expectedBody = "{\n  \"password\" : \"bar\",\n  \"email\" : \"foo@bar.com\"\n}"
        let signinOperation = SigninOperation(persistentContainer: persistentContainer, email: "foo@bar.com", password: "bar")
        
        /// When
        let decodedHTTPBody = String(data: signinOperation.dataRequestOperation.request!.httpBody!, encoding: .utf8)
        
        /// Then
        XCTAssertEqual(decodedHTTPBody, expectedBody)
    }
    
    func testThatSigninOperationShouldHaveSuccess() {
        /// Given
        let expectation = self.expectation(description: "signin operation expectation")
        let credentialStorableMock = CredentialStorableMock()
        let signinOperation = SigninOperation(persistentContainer: persistentContainer,
                                              email: "foo@bar.com",
                                              password: "bar",
                                              credentialStorable: credentialStorableMock)
        var errors: [Error] = []
        
        /// When
        stubResponse("login", fileName: "login", statusCode: 201)
        signinOperation.operationCompletionBlock({ _errors in
            errors = _errors
            expectation.fulfill()
        })
        operationQueue.addOperation(signinOperation)
        
        /// Then
        waitForExpectations(timeout: networkTimeout, handler: nil)
        XCTAssertNotNil(credentialStorableMock.defaultCredential(for: Server.current().protectionSpace!))
        XCTAssertTrue(errors.isEmpty)
        XCTAssertNotNil(User.current(inContext: persistentContainer.viewContext, credentialStorable: credentialStorableMock))
    }
    
    func testThatSigninOperationShouldFail() {
        /// Given
        let expectation = self.expectation(description: "signin operation should fail expectation")
        let credentialStorableMock = CredentialStorableMock()
        let signinOperation = SigninOperation(persistentContainer: persistentContainer,
                                              email: "foo@bar.com",
                                              password: "bar",
                                              credentialStorable: credentialStorableMock)
        var errors: [Error] = []
        var producedNewOperation = false
        
        /// When
        stubResponse("login", fileName: "empty", statusCode: 400)
        signinOperation.operationCompletionBlock({ _errors in
            errors = _errors
            expectation.fulfill()
        })
        signinOperation.addObserver(BlockObserver(produceHandler: { _, _ in
            producedNewOperation = true
        }))
        operationQueue.addOperation(signinOperation)
        
        /// Then
        waitForExpectations(timeout: networkTimeout, handler: nil)
        XCTAssertNil(credentialStorableMock.defaultCredential(for: Server.current().protectionSpace!))
        XCTAssertFalse(errors.isEmpty)
        XCTAssertTrue(producedNewOperation)
    }
    
    func testThatSigninOperationShouldFailForEmptyToken() {
        /// Given
        let expectation = self.expectation(description: "signin operation should fail for empty token expectation")
        let credentialStorableMock = CredentialStorableMock()
        let signinOperation = SigninOperation(persistentContainer: persistentContainer,
                                              email: "foo@bar.com",
                                              password: "bar",
                                              credentialStorable: credentialStorableMock)
        var errors: [Error] = []
        var producedNewOperation = false
        
        /// When
        stubResponse("login", fileName: "login_without_token", statusCode: 201)
        signinOperation.operationCompletionBlock({ _errors in
            errors = _errors
            expectation.fulfill()
        })
        signinOperation.addObserver(BlockObserver(produceHandler: { _, _ in
            producedNewOperation = true
        }))
        operationQueue.addOperation(signinOperation)
        
        /// Then
        waitForExpectations(timeout: networkTimeout, handler: nil)
        XCTAssertNil(credentialStorableMock.defaultCredential(for: Server.current().protectionSpace!))
        XCTAssertFalse(errors.isEmpty)
        XCTAssertTrue(producedNewOperation)
        
        if let error = errors.first as? KountyError {
            XCTAssertTrue(error.isEmptyAuthToken)
        }
        else {
            XCTFail()
        }
    }
    
    func testThatSigninOperationShouldFailWithInvalidCredentials() {
        /// Given
        let expectation = self.expectation(description: "signin operation should fail with invalid credentials")
        let credentialStorableMock = CredentialStorableMock()
        let signinOperation = SigninOperation(persistentContainer: persistentContainer,
                                              email: "foo@bar.com",
                                              password: "bar",
                                              credentialStorable: credentialStorableMock)
        var errors: [Error] = []
        var producedNewOperation = false
        
        /// When
        stubResponse("login", fileName: "login_validation_fail", statusCode: 422)
        signinOperation.operationCompletionBlock({ _errors in
            errors = _errors
            expectation.fulfill()
        })
        signinOperation.addObserver(BlockObserver(produceHandler: { _, _ in
            producedNewOperation = true
        }))
        operationQueue.addOperation(signinOperation)
        
        /// Then
        waitForExpectations(timeout: networkTimeout, handler: nil)
        XCTAssertNil(credentialStorableMock.defaultCredential(for: Server.current().protectionSpace!))
        XCTAssertFalse(errors.isEmpty)
        XCTAssertTrue(producedNewOperation)
        
        if
            /// kounty error
            let error = errors.first as? KountyError,
            
            /// signin validation failure
            let reason = error.reason as? KountyError.ValidationFailedReason {
            
            XCTAssertTrue(reason.isTakenEmail)
            XCTAssertNotNil(reason.message)
        }
        else {
            XCTFail()
        }
    }
}
