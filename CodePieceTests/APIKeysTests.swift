//
//  APIKeysTests.swift
//  CodePieceTests
//
//  Created by Tomohiro Kumagai on 2020/01/12.
//  Copyright © 2020 Tomohiro Kumagai. All rights reserved.
//

import XCTest
@testable import CodePiece

class APIKeysTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testKeysNotEmpty() {

        XCTAssertNotEqual(APIKeys.Twitter.consumerKey, "")
        XCTAssertNotEqual(APIKeys.Twitter.consumerSecret, "")
        XCTAssertNotEqual(APIKeys.GitHub.clientId, "")
        XCTAssertNotEqual(APIKeys.GitHub.clientSecret, "")
    }
}
