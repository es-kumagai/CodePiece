//
//  CodePieceTests.swift
//  CodePieceTests
//
//  Created by Tomohiro Kumagai on H27/07/19.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import XCTest
@testable import CodePiece

import Himotoki
import ESTwitter

class TwitterDecodeTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
	
	private func toJSONObjects(string: String) -> AnyObject? {
		
		guard let data = string.dataUsingEncoding(NSUTF8StringEncoding) else {
			
			return nil
		}
		
		return try? NSJSONSerialization.JSONObjectWithData(data, options: [])
	}
	
    func testCase1() {
		
		let jsonString = "10"
		let objects = toJSONObjects(jsonString)!

		try! decode(objects) as ESTwitter.Status
    }
}
