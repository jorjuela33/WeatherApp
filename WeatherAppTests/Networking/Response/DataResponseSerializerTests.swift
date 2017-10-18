//
//  DataResponseSerializerTests.swift
//  KountyTests
//
//  Created by Jorge Orjuela on 9/15/17.
//  Copyright © 2017 Kounty. All rights reserved.
//

import XCTest
@testable import Kounty

class DataResponseSerializerTests: KountyBaseTests {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    private let error = URLRequestOperationError.inputDataNil
    
    // MARK: Tests - Data Response Serializer
    
    func testThatDataResponseSerializerSucceedsWhenDataIsNotEmpty() {
        /// Given
        let serializer = DataResponseSerializer()
        let data = "data".data(using: .utf8)!
        
        /// When
        let result = serializer.serialize(request: nil, response: nil, data: data, errors: [])
        
        /// Then
        XCTAssertTrue(result.isSuccess)
        XCTAssertNotNil(result.value)
        XCTAssertNil(result.error)
    }
    
    func testThatDataResponseSerializerFailsWhenDataIsEmpty() {
        /// Given
        let serializer = DataResponseSerializer()
        
        /// When
        let result = serializer.serialize(request: nil, response: nil, data: Data(), errors: [])
        
        /// Then
        XCTAssertTrue(result.isFailure)
        XCTAssertNil(result.value)
        XCTAssertNotNil(result.error)
        XCTAssertTrue(result.error is URLRequestOperationError)
    }
    
    func testThatDataResponseSerializerFailsWhenErrorsIsNotEmpty() {
        /// Given
        let serializer = DataResponseSerializer()
        
        /// When
        let result = serializer.serialize(request: nil, response: nil, data: Data(), errors: [error])
        
        /// Then
        XCTAssertTrue(result.isFailure)
        XCTAssertNil(result.value)
        XCTAssertNotNil(result.error)
        XCTAssertTrue(result.error is URLRequestOperationError)
    }
    
    func testThatDataResponseSerializerFailsWhenDataIsEmptyWithNonEmptyResponseStatusCode() {
        // Given
        let serializer = DataResponseSerializer()
        let response = HTTPURLResponse(url: URL(string: "https://httpbin.org")!, statusCode: 200, httpVersion: nil, headerFields: nil)
        
        // When
        let result = serializer.serialize(request: nil, response: response, data: Data(), errors: [])
        
        // Then
        XCTAssertTrue(result.isFailure, "result is failure should be true")
        XCTAssertNil(result.value, "result value should be nil")
        XCTAssertNotNil(result.error, "result error should not be nil")
        XCTAssertTrue(result.error is URLRequestOperationError)
    }
    
    func testThatDataResponseSerializerSucceedsWhenDataIsEmptyWithEmptyResponseStatusCode() {
        // Given
        let serializer = DataResponseSerializer()
        let response = HTTPURLResponse(url: URL(string: "https://httpbin.org")!, statusCode: 204, httpVersion: nil, headerFields: nil)
        
        // When
        let result = serializer.serialize(request: nil, response: response, data: Data(), errors: [])
        
        // Then
        XCTAssertTrue(result.isSuccess)
        XCTAssertNotNil(result.value)
        XCTAssertNil(result.error)
        
        if let data = result.value {
            XCTAssertEqual(data.count, 0)
        }
    }
}
