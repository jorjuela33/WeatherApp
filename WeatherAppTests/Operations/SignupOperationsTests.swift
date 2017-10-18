//
//  SignupOperationsTests.swift
//  KountyTests
//
//  Created by Jorge Orjuela on 9/15/17.
//  Copyright © 2017 Kounty. All rights reserved.
//

import CoreData.NSPersistentContainer
import OHHTTPStubs
import XCTest
@testable import Kounty

class SignupOperationsTests: KountyBaseTests {
    
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
    
    func testThatSignupOperationInitialization() {
        /// Given
        let expectedBody = "{\n  \"password_confirmation\" : \"1345\",\n  \"email\" : \"foo@goo.com\",\n  \"last_name\" : \"User\",\n  \"cellphone\" : \"3045600841\",\n  \"password\" : \"1345\",\n  \"first_name\" : \"Test\"\n}"
        let signupOperation = SignupOperation(persistentContainer: persistentContainer,
                                              email: "foo@goo.com",
                                              password: "1345",
                                              firstName: "Test",
                                              lastName: "User",
                                              phoneNumber: "3045600841")
        
        /// When
        let decodedHTTPBody = String(data: signupOperation.dataRequestOperation.request!.httpBody!, encoding: .utf8)
        
        /// Then
        XCTAssertEqual(decodedHTTPBody, expectedBody)
    }
    
    func testThatSignupOperationShouldHaveSuccess() {
        /// Given
        let expectation = self.expectation(description: "signup operation expectation")
        let credentialStorableMock = CredentialStorableMock()
        let signupOperation = SignupOperation(persistentContainer: persistentContainer,
                                              email: "foo@goo.com",
                                              password: "1345",
                                              firstName: "Test",
                                              lastName: "User",
                                              phoneNumber: "3045600841",
                                              credentialStorable: credentialStorableMock)
        var errors: [Error] = []
        
        /// When
        stubResponse("signup", fileName: "signup", statusCode: 201)
        signupOperation.operationCompletionBlock({ _errors in
            errors = _errors
            expectation.fulfill()
        })
        operationQueue.addOperation(signupOperation)
        
        /// Then
        waitForExpectations(timeout: networkTimeout, handler: nil)
        XCTAssertNotNil(credentialStorableMock.defaultCredential(for: Server.current().protectionSpace!))
        XCTAssertTrue(errors.isEmpty)
        XCTAssertNotNil(User.current(inContext: persistentContainer.viewContext, credentialStorable: credentialStorableMock))
    }
    
    func testThatSignupOperationShouldFail() {
        /// Given
        let expectation = self.expectation(description: "signup operation should fail expectation")
        let credentialStorableMock = CredentialStorableMock()
        let signupOperation = SignupOperation(persistentContainer: persistentContainer,
                                              email: "foo@goo.com",
                                              password: "1345",
                                              firstName: "Test",
                                              lastName: "User",
                                              phoneNumber: "3045600841",
                                              credentialStorable: credentialStorableMock)
        var errors: [Error] = []
        var producedNewOperation = false
        
        /// When
        stubResponse("signup", fileName: "empty", statusCode: 400)
        signupOperation.operationCompletionBlock({ _errors in
            errors = _errors
            expectation.fulfill()
        })
        signupOperation.addObserver(BlockObserver(produceHandler: { _, _ in
            producedNewOperation = true
        }))
        operationQueue.addOperation(signupOperation)
        
        /// Then
        waitForExpectations(timeout: networkTimeout, handler: nil)
        XCTAssertNil(credentialStorableMock.defaultCredential(for: Server.current().protectionSpace!))
        XCTAssertFalse(errors.isEmpty)
        XCTAssertTrue(producedNewOperation)
    }
    
    func testThatSignupOperationShouldFailForEmptyToken() {
        /// Given
        let expectation = self.expectation(description: "signup operation should fail for empty token expectation")
        let credentialStorableMock = CredentialStorableMock()
        let signupOperation = SignupOperation(persistentContainer: persistentContainer,
                                              email: "foo@goo.com",
                                              password: "1345",
                                              firstName: "Test",
                                              lastName: "User",
                                              phoneNumber: "3045600841",
                                              credentialStorable: credentialStorableMock)
        var errors: [Error] = []
        var producedNewOperation = false
        
        /// When
        stubResponse("signup", fileName: "signup_without_token", statusCode: 201)
        signupOperation.operationCompletionBlock({ _errors in
            errors = _errors
            expectation.fulfill()
        })
        signupOperation.addObserver(BlockObserver(produceHandler: { _, _ in
            producedNewOperation = true
        }))
        operationQueue.addOperation(signupOperation)
        
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
    
    func testThatSignupOperationShouldFailWithInvalidParameters() {
        /// Given
        let expectation = self.expectation(description: "signup operation should fail with invalid parameters")
        let credentialStorableMock = CredentialStorableMock()
        let signupOperation = SignupOperation(persistentContainer: persistentContainer,
                                              email: "fooo.com",
                                              password: "1345",
                                              firstName: "Test",
                                              lastName: "User",
                                              phoneNumber: "3045600841",
                                              credentialStorable: credentialStorableMock)
        var errors: [Error] = []
        var producedNewOperation = false
        
        /// When
        stubResponse("signup", fileName: "signup_validation_fail", statusCode: 422)
        signupOperation.operationCompletionBlock({ _errors in
            errors = _errors
            expectation.fulfill()
        })
        signupOperation.addObserver(BlockObserver(produceHandler: { _, _ in
            producedNewOperation = true
        }))
        operationQueue.addOperation(signupOperation)
        
        /// Then
        waitForExpectations(timeout: networkTimeout, handler: nil)
        XCTAssertNil(credentialStorableMock.defaultCredential(for: Server.current().protectionSpace!))
        XCTAssertFalse(errors.isEmpty)
        XCTAssertTrue(producedNewOperation)
        
        if /// kounty error
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
