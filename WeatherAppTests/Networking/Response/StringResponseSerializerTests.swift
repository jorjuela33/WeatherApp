//
//  StringResponseSerializerTests.swift
//  WeatherAppTests
//
//  Created by Jorge Orjuela on 10/18/17.
//

import XCTest
@testable import WeatherApp

class StringResponseSerializerTests: WeatherAppBaseTests {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testThatStringResponseSerializerSucceedsWhenDataIsEmpty() {
        /// Given
        let serializer = StringResponseSerializer()
        
        /// When
        let result = serializer.serialize(request: nil, response: nil, data: Data(), errors: [])
        
        /// Then
        XCTAssertTrue(result.isFailure)
        XCTAssertNil(result.value)
        XCTAssertNotNil(result.error)
        XCTAssertTrue(result.error is URLRequestOperationError)
    }
    
    func testThatStringResponseSerializerSucceedsWithEncoding() {
        /// Given
        let serializer = StringResponseSerializer()
        let data = "data".data(using: .utf8)!
        
        /// When
        let result = serializer.serialize(request: nil, response: nil, data: data, errors: [])
        
        /// Then
        XCTAssertTrue(result.isSuccess)
        XCTAssertNotNil(result.value)
        XCTAssertNil(result.error)
    }
    
    func testThatStringResponseSerializerSucceedsWithUTF8DataAndUTF8Encoding() {
        /// Given
        let serializer = StringResponseSerializer()
        let data = "data".data(using: .utf8)!
        
        /// When
        let result = serializer.serialize(request: nil, response: nil, data: data, errors: [])
        
        /// Then
        XCTAssertTrue(result.isSuccess)
        XCTAssertNotNil(result.value)
        XCTAssertNil(result.error)
    }
    
    func testThatStringResponseSerializerSucceedsWithUTF8DataAndTextResponseEncoding() {
        /// Given
        let serializer = StringResponseSerializer()
        let data = "data".data(using: .utf8)!
        let response = HTTPURLResponse(url: URL(string: "https://httpbin.org")!, statusCode: 200, httpVersion: nil, headerFields: ["Content-Type": "image/jpeg; charset=utf-8"])
        
        /// When
        let result = serializer.serialize(request: nil, response: response, data: data, errors: [])
        
        /// Then
        XCTAssertTrue(result.isSuccess)
        XCTAssertNotNil(result.value)
        XCTAssertNil(result.error)
    }
    
    func testThatStringResponseSerializerFailsUsingUTF32DataAndUTF8Encoding() {
        /// Given
        let serializer = StringResponseSerializer()
        let data = "foo".data(using: .utf32)!
        
        /// When
        let result = serializer.serialize(request: nil, response: nil, data: data, errors: [])
        
        /// Then
        XCTAssertTrue(result.isFailure)
        XCTAssertNil(result.value)
        XCTAssertNotNil(result.error)
        XCTAssertTrue(result.error is URLRequestOperationError)
    }
    
    func testThatStringResponseSerializerFailsWhenErrorIsNotNil() {
        /// Given
        let serializer = StringResponseSerializer()
        
        /// When
        let result = serializer.serialize(request: nil, response: nil, data: Data(), errors: [URLRequestOperationError.inputDataNil])
        
        /// Then
        XCTAssertTrue(result.isFailure)
        XCTAssertNil(result.value)
        XCTAssertNotNil(result.error)
        XCTAssertTrue(result.error is URLRequestOperationError)
    }
    
    func testThatStringResponseSerializerFailsWhenDataIsEmptyWithNonEmptyResponseStatusCode() {
        /// Given
        let serializer = StringResponseSerializer()
        let response = HTTPURLResponse(url: URL(string: "https://httpbin.org")!, statusCode: 200, httpVersion: nil, headerFields: nil)
        
        /// When
        let result = serializer.serialize(request: nil, response: response, data: Data(), errors: [])
        
        /// Then
        XCTAssertTrue(result.isFailure)
        XCTAssertNil(result.value)
        XCTAssertNotNil(result.error)
        XCTAssertTrue(result.error is URLRequestOperationError)
    }
    
    func testThatStringResponseSerializerSucceedsWhenDataIsEmptyWithEmptyResponseStatusCode() {
        /// Given
        let serializer = StringResponseSerializer()
        let response = HTTPURLResponse(url: URL(string: "https://httpbin.org")!, statusCode: 205, httpVersion: nil, headerFields: nil)
        
        /// When
        let result = serializer.serialize(request: nil, response: response, data: Data(), errors: [])
        
        /// Then
        XCTAssertTrue(result.isSuccess)
        XCTAssertNotNil(result.value)
        XCTAssertNil(result.error)
        
        if let string = result.value {
            XCTAssertEqual(string, "")
        }
    }
}
