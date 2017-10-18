//
//  ParameterEncodingTests.swift
//  KountyTests
//
//  Created by Jorge Orjuela on 9/15/17.
//  Copyright © 2017 Kounty. All rights reserved.
//

import XCTest
@testable import Kounty

class ParameterEncodingTests: KountyBaseTests {
    
    private let request = URLRequest(url: URL(string: "https://httpbin.org")!)
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    // MARK: URL Encoding tests
    
    func testURLParameterEncodingEncodeNilParameters() {
        /// Given
        let request = ParameterEncoding.url.encode(self.request, parameters: nil).0
        
        /// When
        
        /// Then
        XCTAssertNil(request.url?.query)
    }
    
    func testURLParameterEncodingEncodeEmptyDictionary() {
        /// Given
        let parameters: [String: Any] = [:]
        let request = ParameterEncoding.url.encode(self.request, parameters: parameters).0
        
        /// When
        
        /// Then
        XCTAssertNil(request.url?.query)
    }
    
    func testURLParameterEncodingEncodeStringKeyAndStringValueParameter() {
        /// Given
        let parameters = ["foo": "bar"]
        
        /// When
        let request = ParameterEncoding.url.encode(self.request, parameters: parameters).0
        
        /// Then
        XCTAssertEqual(request.url?.query, "foo=bar")
    }
    
    func testURLParameterEncodingEncodeStringKeyAndStringValueParameterAppendedToQuery() {
        /// Given
        var mutableURLRequest = self.request
        let parameters = ["foo": "bar"]
        var urlComponents = URLComponents(url: mutableURLRequest.url!, resolvingAgainstBaseURL: false)!
        urlComponents.query = "baz=qux"
        mutableURLRequest.url = urlComponents.url
        
        /// When
        let request = ParameterEncoding.url.encode(mutableURLRequest, parameters: parameters).0
        
        /// Then
        XCTAssertEqual(request.url?.query, "baz=qux&foo=bar")
    }
    
    func testURLParameterEncodingEncodeMultipleStringKeyAndStringValueParameters() {
        /// Given
        let parameters = ["foo": "bar", "baz": "qux"]
        
        /// When
        let request = ParameterEncoding.url.encode(self.request, parameters: parameters).0
        
        /// Then
        XCTAssertEqual(request.url?.query, "baz=qux&foo=bar")
    }
    
    func testURLParameterEncodingEncodeStringKeyAndNumberIntegerValueParameter() {
        /// Given
        let parameters = ["foo": 25]
        
        /// When
        let request = ParameterEncoding.url.encode(self.request, parameters: parameters).0
        
        /// Then
        XCTAssertEqual(request.url?.query, "foo=25")
    }
    
    func testURLParameterEncodingEncodeStringKeyAndNSNumberBoolValueParameter() {
        /// Given
        let parameters = ["foo": NSNumber(value: false)]
        
        /// When
        let request = ParameterEncoding.url.encode(self.request, parameters: parameters).0
        
        /// Then
        XCTAssertEqual(request.url?.query, "foo=0")
    }
    
    func testURLParameterEncodingEncodeStringKeyAndIntegerValueParameter() {
        // Given
        let parameters = ["foo": 1]
        
        // When
        let request = ParameterEncoding.url.encode(self.request, parameters: parameters).0
        
        // Then
        XCTAssertEqual(request.url?.query, "foo=1")
    }
    
    func testURLParameterEncodingEncodeStringKeyAndDoubleValueParameter() {
        /// Given
        let parameters = ["foo": 1.1]
        
        /// When
        let request = ParameterEncoding.url.encode(self.request, parameters: parameters).0
        
        /// Then
        XCTAssertEqual(request.url?.query, "foo=1.1")
    }
    
    func testURLParameterEncodingEncodeStringKeyAndBoolValueParameter() {
        /// Given
        let parameters = ["foo": true]
        
        /// When
        let request = ParameterEncoding.url.encode(self.request, parameters: parameters).0
        
        /// Then
        XCTAssertEqual(request.url?.query, "foo=true")
    }
    
    func testURLParameterEncodingEncodeStringAndKeyDictionaryValueParameter() {
        /// Given
        let parameters = ["foo": ["bar": 1]]
        
        /// When
        let request = ParameterEncoding.url.encode(self.request, parameters: parameters).0
        
        /// Then
        XCTAssertEqual(request.url?.query, "foo%5Bbar%5D=1")
    }
    
    func testURLParameterEncodingEncodeStringKeyAndNestedDictionaryValueParameter() {
        /// Given
        let parameters = ["foo": ["bar": ["baz": 1]]]
        
        /// When
        let request = ParameterEncoding.url.encode(self.request, parameters: parameters).0
        
        /// Then
        XCTAssertEqual(request.url?.query, "foo%5Bbar%5D%5Bbaz%5D=1")
    }
    
    func testThatReservedCharacters() {
        /// Given
        let generalDelimiters = ":#[]@"
        let subDelimiters = "!$&'()*+,;="
        let parameters = ["reserved": "\(generalDelimiters)\(subDelimiters)"]
        let expectedQuery = "reserved=%3A%23%5B%5D%40%21%24%26%27%28%29%2A%2B%2C%3B%3D"
        
        /// When
        let request = ParameterEncoding.url.encode(self.request, parameters: parameters).0
        
        /// Then
        XCTAssertEqual(request.url?.query, expectedQuery)
    }
    
    func testThatReservedCharactersAreNotPercentEscaped() {
        /// Given
        let parameters = ["reserved": "?/"]
        
        /// When
        let request = ParameterEncoding.url.encode(self.request, parameters: parameters).0
        
        /// Then
        XCTAssertEqual(request.url?.query, "reserved=?/")
    }
    
    func testThatUnreservedNumericCharactersAreNotEscaped() {
        /// Given
        let parameters = ["numbers": "0123456789"]
        
        /// When
        let request = ParameterEncoding.url.encode(self.request, parameters: parameters).0
        
        /// Then
        XCTAssertEqual(request.url?.query, "numbers=0123456789")
    }
    
    func testThatUnreservedLowercaseCharactersAreNotPercentEscaped() {
        /// Given
        let parameters = ["lowercase": "abcdefghijklmnopqrstuvwxyz"]
        
        /// When
        let request = ParameterEncoding.url.encode(self.request, parameters: parameters).0
        
        /// Then
        XCTAssertEqual(request.url?.query, "lowercase=abcdefghijklmnopqrstuvwxyz")
    }
    
    func testThatUnreservedUppercaseCharactersAreNotPercentEscaped() {
        /// Given
        let parameters = ["uppercase": "ABCDEFGHIJKLMNOPQRSTUVWXYZ"]
        
        /// When
        let request = ParameterEncoding.url.encode(self.request, parameters: parameters).0
        
        /// Then
        XCTAssertEqual(request.url?.query, "uppercase=ABCDEFGHIJKLMNOPQRSTUVWXYZ")
    }
    
    func testThatASCIICharactersArePercentEscaped() {
        /// Given
        let parameters = ["illegal": " \"#%<>[]\\^`{}|"]
        let expectedQuery = "illegal=%20%22%23%25%3C%3E%5B%5D%5C%5E%60%7B%7D%7C"
        
        /// When
        let request = ParameterEncoding.url.encode(self.request, parameters: parameters).0
        
        /// Then
        XCTAssertEqual(request.url?.query, expectedQuery)
    }
    
    func testURLParameterEncodingEncodeStringWithAmpersandKeyStringAndWithAmpersandValueParameter() {
        /// Given
        let parameters = ["foo&bar": "baz&qux", "foobar": "bazqux"]
        
        /// When
        let request = ParameterEncoding.url.encode(self.request, parameters: parameters).0
        
        /// Then
        XCTAssertEqual(request.url?.query, "foo%26bar=baz%26qux&foobar=bazqux")
    }
    
    func testURLParameterEncodingEncodeStringWithQuestionAndMarkKeyStringWithQuestionMarkValueParameter() {
        /// Given
        let parameters = ["?foo?": "?bar?"]
        
        /// When
        let request = ParameterEncoding.url.encode(self.request, parameters: parameters).0
        
        /// Then
        XCTAssertEqual(request.url?.query, "?foo?=?bar?")
    }
    
    func testURLParameterEncodingEncodeStringWithSlashKeyStringAndQuestionMarkValueParameter() {
        /// Given
        let parameters = ["foo": "/bar/baz/qux"]
        
        /// When
        let request = ParameterEncoding.url.encode(self.request, parameters: parameters).0
        
        /// Then
        XCTAssertEqual(request.url?.query, "foo=/bar/baz/qux")
    }
    
    func testURLParameterEncodingEncodeStringWithSpaceKeyStringAndSpaceValueParameter() {
        /// Given
        let parameters = [" foo ": " bar "]
        
        /// When
        let request = ParameterEncoding.url.encode(self.request, parameters: parameters).0
        
        /// Then
        XCTAssertEqual(request.url?.query, "%20foo%20=%20bar%20")
    }
    
    func testURLParameterEncodingEncodeStringWithPlusKeyStringAndPlusValueParameter() {
        /// Given
        let parameters = ["+foo+": "+bar+"]
        
        /// When
        let request = ParameterEncoding.url.encode(self.request, parameters: parameters).0
        
        /// Then
        XCTAssertEqual(request.url?.query, "%2Bfoo%2B=%2Bbar%2B")
    }
    
    func testURLParameterEncodingEncodeStringKeyPercentAndEncodedStringValueParameter() {
        /// Given
        let parameters = ["percent": "%25"]
        
        /// When
        let request = ParameterEncoding.url.encode(self.request, parameters: parameters).0
        
        /// Then
        XCTAssertEqual(request.url?.query, "percent=%2525")
    }
    
    func testURLParameterEncodingEncodeStringKeyNonLatinAndStringValueParameter() {
        /// Given
        let parameters = ["french": "français", "japanese": "日本語", "arabic": "العربية", "emoji": "😃"]
        let expectedParameters = ["arabic=%D8%A7%D9%84%D8%B9%D8%B1%D8%A8%D9%8A%D8%A9", "emoji=%F0%9F%98%83", "french=fran%C3%A7ais", "japanese=%E6%97%A5%E6%9C%AC%E8%AA%9E"]
        let expectedQuery = expectedParameters.joined(separator: "&")
        
        /// When
        let request = ParameterEncoding.url.encode(self.request, parameters: parameters).0
        
        /// Then
        XCTAssertEqual(request.url?.query, expectedQuery)
    }
    
    func testURLParameterEncodingEncodeStringForRequestAndPrecomposedQuery() {
        /// Given
        let url = URL(string: "https://example.com/movies?hd=[1]")!
        let parameters = ["page": "0"]
        
        /// When
        let request = ParameterEncoding.url.encode(URLRequest(url: url), parameters: parameters).0
        
        /// Then
        XCTAssertEqual(request.url?.query, "hd=%5B1%5D&page=0")
    }
    
   func testURLParameterEncodingEncodeStringWithPlusKeyStringAndPlusValueParameterForRequestWithPrecomposedQuery() {
        /// Given
        let url = URL(string: "https://example.com/movie?hd=[1]")!
        let parameters = ["+foo+": "+bar+"]
    
        // When
        let request = ParameterEncoding.url.encode(URLRequest(url: url), parameters: parameters).0
    
        // Then
        XCTAssertEqual(request.url?.query, "hd=%5B1%5D&%2Bfoo%2B=%2Bbar%2B")
    }
    
    func testThatURLParameterEncodingEncodesGETParametersInURL() {
        /// Given
        var mutableURLRequest = self.request
        mutableURLRequest.httpMethod = HTTPMethod.GET.rawValue
        let parameters = ["foo": 1, "bar": 2]
        
        /// When
        let request = ParameterEncoding.url.encode(self.request, parameters: parameters).0
        
        /// Then
        XCTAssertEqual(request.url?.query, "bar=2&foo=1")
        XCTAssertNil(request.value(forHTTPHeaderField: "Content-Type"))
        XCTAssertNil(request.httpBody)
    }
    
    func testThatURLParameterEncodingEncodesPOSTParametersInHTTPBody() {
        /// Given
        var mutableURLRequest = self.request
        mutableURLRequest.httpMethod = HTTPMethod.POST.rawValue
        let parameters = ["foo": 1, "bar": 2]
        
        /// When
        let request = ParameterEncoding.url.encode(mutableURLRequest, parameters: parameters).0
        
        /// Then
        XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "application/x-www-form-urlencoded; charset=utf-8")
        XCTAssertNotNil(request.httpBody)
        
        if let httpBody = request.httpBody, let decodedHTTPBody = String(data: httpBody, encoding: .utf8) {
            XCTAssertEqual(decodedHTTPBody, "bar=2&foo=1")
        }
        else {
            XCTFail("decoded http body should not be nil")
        }
    }
    
    func testJSONParameterEncodingEncodeNilParameters() {
        /// Given
        let request = ParameterEncoding.json.encode(self.request, parameters: nil).0
        
        /// When
        
        // Then
        XCTAssertNil(request.url?.query)
        XCTAssertNil(request.value(forHTTPHeaderField: "Content-Type"))
        XCTAssertNil(request.httpBody)
    }
    
    func testJSONParameterEncodingEncodeComplexParameters() {
        /// Given
        let parameters: [String: Any] = ["foo": "bar","baz": ["a", 1, true], "qux": ["a": 1, "b": [2, 2], "c": [3, 3, 3]]]
        
        /// When
        let request = ParameterEncoding.json.encode(self.request, parameters: parameters).0
        
        /// Then
        XCTAssertNil(request.url?.query)
        XCTAssertNotNil(request.value(forHTTPHeaderField: "Content-Type"))
        XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "application/json")
        XCTAssertNotNil(request.httpBody)
        
        if let httpBody = request.httpBody {
            do {
                let JSONObject = try JSONSerialization.jsonObject(with: httpBody, options: .allowFragments)
                
                if let JSONObject = JSONObject as? NSObject {
                    XCTAssertEqual(JSONObject, parameters as NSObject)
                }
                else {
                    XCTFail()
                }
            }
            catch {
                XCTFail()
            }
        }
        else {
            XCTFail()
        }
    }
    
    func testJSONParameterEncodingEncodeArray() {
        /// Given
        let parameters = ["foo", "bar", "baz"]
        
        /// When
        let request = ParameterEncoding.json.encode(self.request, parameters: parameters).0
        
        /// Then
        XCTAssertNil(request.url?.query)
        XCTAssertNotNil(request.value(forHTTPHeaderField: "Content-Type"))
        XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "application/json")
        XCTAssertNotNil(request.httpBody)
        
        if let httpBody = request.httpBody {
            do {
                let JSONObject = try JSONSerialization.jsonObject(with: httpBody, options: .allowFragments)
                
                if let JSONObject = JSONObject as? NSObject {
                    XCTAssertEqual(JSONObject, parameters as NSObject)
                }
                else {
                    XCTFail()
                }
            }
            catch {
                XCTFail()
            }
        }
    }
    
    func testJSONParameterEncodingEncodeParametersRetainsCustomContentType() {
        /// Given
        var mutableURLRequest = URLRequest(url: URL(string: "https://example.com/")!)
        mutableURLRequest.setValue("application/custom-type", forHTTPHeaderField: "Content-Type")
        let parameters = ["foo": "bar"]
        
        /// When
        let request = ParameterEncoding.json.encode(mutableURLRequest, parameters: parameters).0
        
        /// Then
        XCTAssertNil(request.url?.query)
        XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "application/custom-type")
    }
}
