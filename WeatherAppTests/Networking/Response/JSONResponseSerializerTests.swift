//
//  JSONResponseSerializerTests.swift
//  WeatherAppTests
//
//  Created by Jorge Orjuela on 10/18/17.
//

import XCTest
@testable import WeatherApp

class JSONResponseSerializerTests: WeatherAppBaseTests {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    // MARK: Tests
    
    func testThatJSONResponseSerializerFailsWhenDataIsEmpty() {
        /// Given
        let serializer = JSONResponseSerializer()
        
        /// When
        let result = serializer.serialize(request: nil, response: nil, data: Data(), errors: [])
        
        /// Then
        XCTAssertTrue(result.isFailure)
        XCTAssertNil(result.value)
        XCTAssertNotNil(result.error)
        XCTAssertTrue(result.error is URLRequestOperationError)
    }
    
    func testThatJSONResponseSerializerSucceedsWhenDataIsValidJSON() {
        /// Given
        let serializer = JSONResponseSerializer()
        let data = "{\"json\": true}".data(using: .utf8)!
        
        /// When
        let result = serializer.serialize(request: nil, response: nil, data: data, errors: [])
        
        /// Then
        XCTAssertTrue(result.isSuccess)
        XCTAssertNotNil(result.value)
        XCTAssertNil(result.error)
    }
    
    func testThatJSONResponseSerializerFailsWhenDataIsInvalidJSON() {
        /// Given
        let serializer = JSONResponseSerializer()
        let data = "not valid json".data(using: .utf8)!
        
        /// When
        let result = serializer.serialize(request: nil, response: nil, data: data, errors: [])
        
        /// Then
        XCTAssertTrue(result.isFailure)
        XCTAssertNil(result.value)
        XCTAssertNotNil(result.error)
        XCTAssertTrue(result.error is URLRequestOperationError)
    }
    
    func testThatJSONResponseSerializerFailsWhenErrorIsNotNil() {
        /// Given
        let serializer = JSONResponseSerializer()
        
        /// When
        let result = serializer.serialize(request: nil, response: nil, data: Data(), errors: [URLRequestOperationError.inputDataNil])
        
        /// Then
        XCTAssertTrue(result.isFailure)
        XCTAssertNil(result.value)
        XCTAssertNotNil(result.error)
        XCTAssertTrue(result.error is URLRequestOperationError)
    }
    
    func testThatJSONResponseSerializerFailsWhenDataIsEmptyWithNonEmptyResponseStatusCode() {
        /// Given
        let serializer = JSONResponseSerializer()
        let response = HTTPURLResponse(url: URL(string: "https://httpbin.org")!, statusCode: 200, httpVersion: nil, headerFields: nil)
        
        /// When
        let result = serializer.serialize(request: nil, response: response, data: Data(), errors: [])
        
        /// Then
        XCTAssertTrue(result.isFailure)
        XCTAssertNil(result.value)
        XCTAssertNotNil(result.error)
        XCTAssertTrue(result.error is URLRequestOperationError)
    }
    
    func testThatJSONResponseSerializerSucceedsWhenDataIsNilWithEmptyResponseStatusCode() {
        /// Given
        let serializer = JSONResponseSerializer()
        let response = HTTPURLResponse(url: URL(string: "https://httpbin.org")!, statusCode: 204, httpVersion: nil, headerFields: nil)
        
        /// When
        let result = serializer.serialize(request: nil, response: response, data: Data(), errors: [])
        
        /// Then
        XCTAssertTrue(result.isSuccess)
        XCTAssertNotNil(result.value)
        XCTAssertNil(result.error)
        
        if let json = result.value as? NSNull {
            XCTAssertEqual(json, NSNull())
        }
    }
}
