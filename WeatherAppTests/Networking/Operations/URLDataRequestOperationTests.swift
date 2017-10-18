//
//  URLDataRequestOperationTests.swift
//  WeatherAppTests
//
//  Created by Jorge Orjuela on 10/18/17.
//

import XCTest
@testable import WeatherApp

class URLDataRequestOperationTests: WeatherAppBaseTests {
    
    private lazy var session: URLSession = {
       return URLSession(configuration: URLSessionConfiguration.default, delegate: self.sessionDelegate, delegateQueue: nil)
    }()
    private let sessionDelegate = SessionDelegate()
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    // MARK: Tests
    
    func testThatDataRequestInitialization() {
        /// Given
        let urlString = "https://httpbin.org/get"
        let task = session.dataTask(with: URL(string: urlString)!)
        
        /// When
        let requestOperation = URLDataRequestOperation(session: URLSession.shared, task: task)
        
        /// Then
        XCTAssertNotNil(requestOperation.request)
        XCTAssertEqual(requestOperation.request?.httpMethod, "GET")
        XCTAssertEqual(requestOperation.request?.url?.absoluteString, urlString)
        XCTAssertNil(requestOperation.response)
    }
    
    func testThatDataRequestCompletionBlockShouldBeInvoked() {
        /// Given
        let expectation = self.expectation(description: "Request completion should be invoked")
        let task = session.dataTask(with: URL(string: "https://httpbin.org/get")!)
        let requestOperation = URLDataRequestOperation(session: URLSession.shared, task: task)
        
        /// When
        requestOperation.requestCompletionBlock { _ in
            expectation.fulfill()
        }
        sessionDelegate[task] = requestOperation
        requestOperation.resume()
        
        /// Then
        waitForExpectations(timeout: networkTimeout, handler: nil)
        XCTAssertNotNil(requestOperation.response)
    }
    
    func testThatDataRequestResponseShouldNotBeNil() {
        /// Given
        let expectation = self.expectation(description: "Request completion should be invoked")
        let task = session.dataTask(with: URL(string: "https://httpbin.org/get")!)
        let requestOperation = URLDataRequestOperation(session: URLSession.shared, task: task)
        
        /// When
        requestOperation.requestCompletionBlock { _ in
            expectation.fulfill()
        }
        sessionDelegate[task] = requestOperation
        requestOperation.resume()
        
        /// Then
        waitForExpectations(timeout: networkTimeout, handler: nil)
        XCTAssertNotNil(requestOperation.response)
    }
    
    func testThatDataRequestShouldFailByValidations() {
        /// Given
        let expectation = self.expectation(description: "Request completion should be invoked")
        let task = session.dataTask(with: URL(string: "https://httpbin.org/get")!)
        let requestOperation = URLDataRequestOperation(session: URLSession.shared, task: task)
        var errors: [Error] = []
        
        /// When
        requestOperation.requestCompletionBlock { _errors in
            errors = _errors
            expectation.fulfill()
        }
        sessionDelegate[task] = requestOperation
        requestOperation.validate(acceptableStatusCodes: [400])
        requestOperation.resume()
        
        /// Then
        waitForExpectations(timeout: networkTimeout, handler: nil)
        XCTAssertFalse(errors.isEmpty)
    }
    
    func testThatDataRequestShouldInvokeResponseDataBlock() {
        /// Given
        let expectation = self.expectation(description: "Request data response should be invoked")
        let task = session.dataTask(with: URL(string: "https://httpbin.org/get")!)
        let requestOperation = URLDataRequestOperation(session: URLSession.shared, task: task)
        var isInvoked = false
        
        /// When
        requestOperation.responseData(completionHandler: { _ in
            isInvoked = true
            expectation.fulfill()
        })
        sessionDelegate[task] = requestOperation
        requestOperation.resume()
        
        /// Then
        waitForExpectations(timeout: networkTimeout, handler: nil)
        XCTAssertTrue(isInvoked)
    }
    
    func testThatDataRequestShouldInvokeResponseJSONBlock() {
        /// Given
        let expectation = self.expectation(description: "Request JSON block should be invoked")
        let task = session.dataTask(with: URL(string: "https://httpbin.org/get")!)
        let requestOperation = URLDataRequestOperation(session: URLSession.shared, task: task)
        var isInvoked = false
        
        /// When
        requestOperation.responseJSON(completionHandler: { _ in
            isInvoked = true
            expectation.fulfill()
        })
        sessionDelegate[task] = requestOperation
        requestOperation.resume()
        
        /// Then
        waitForExpectations(timeout: networkTimeout, handler: nil)
        XCTAssertTrue(isInvoked)
    }
    
    func testThatDataRequestShouldInvokeResponseStringBlock() {
        /// Given
        let expectation = self.expectation(description: "Request string block should be invoked")
        let task = session.dataTask(with: URL(string: "https://httpbin.org/get")!)
        let requestOperation = URLDataRequestOperation(session: URLSession.shared, task: task)
        var isInvoked = false
        
        /// When
        requestOperation.responseString(completionHandler: { _ in
            isInvoked = true
            expectation.fulfill()
        })
        sessionDelegate[task] = requestOperation
        requestOperation.resume()
        
        /// Then
        waitForExpectations(timeout: networkTimeout, handler: nil)
        XCTAssertTrue(isInvoked)
    }
}
