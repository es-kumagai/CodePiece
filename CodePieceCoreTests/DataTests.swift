//
//  DataTests.swift
//  CodePieceCoreTests
//
//  Created by kumagai on 2020/05/24.
//  Copyright © 2020 Tomohiro Kumagai. All rights reserved.
//

import XCTest
@testable import CodePieceCore

class DataTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testCode() throws {

		let string1 = """
			let a = 10
			print(a)

			"""
		
		let string2 = """
				
			        
			"""
		
		let code1 = Code(string1)
		let code2 = Code(string2)
		
		XCTAssertFalse(code1.isEmpty)
		XCTAssertTrue(code2.isEmpty)
	}
}
