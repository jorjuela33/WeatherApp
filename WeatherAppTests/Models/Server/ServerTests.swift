//
//  ServerTests.swift
//  KountyTests
//
//  Created by Jorge Orjuela on 10/11/17.
//  Copyright © 2017 Kounty. All rights reserved.
//

import XCTest
@testable import Kounty

class ServerTestCase: KountyBaseTests {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    // MARK: Tests

    func testThatServerInitialization() {
        /// Given
        let url = URL(string: "https://httpbin.org/get")!
        let server = Server(name: "name", url: url)

        /// When

        /// Then
        XCTAssertEqual(server.name, "name")
        XCTAssertEqual(server.url, url)
        XCTAssertEqual(server.version, 1)
        XCTAssertNotNil(server.protectionSpace)
        XCTAssertNotNil(server.apiEndPoint)
    }

    func testThatServerInitializationWithoutURL() {
        /// Given
        let server = Server(name: "name", url: nil)

        /// When

        /// Then
        XCTAssertEqual(server.name, "name")
        XCTAssertNil(server.url)
        XCTAssertNil(server.apiEndPoint)
        XCTAssertNil(server.protectionSpace)
        XCTAssertEqual(server.version, 1)
    }

    func testThatServerInitializationWithVersion() {
        /// Given
        let url = URL(string: "https://httpbin.org/get")!
        let server = Server(name: "name", url: url, version: 2)

        /// When

        /// Then
        XCTAssertEqual(server.name, "name")
        XCTAssertEqual(server.url, url)
        XCTAssertEqual(server.version, 2)
    }

    func testThatSetCurrentServer() {
        /// Given
        let url = URL(string: "https://httpbin.org/get")!
        let server = Server(name: "name", url: url, version: 2)
        let userDefaultsStorableMock = UserDefaultsStorableMock()

        /// When
        Server.set(server, userDefaultStorable: userDefaultsStorableMock)

        /// Then
        XCTAssertEqual(server, Server.current(userDefaultsStorable: userDefaultsStorableMock))
    }
}
