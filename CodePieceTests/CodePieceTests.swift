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
	
	private func readJSON(name: String) -> AnyObject {
		
		let bundle = NSBundle(forClass: TwitterDecodeTests.self)
		let file = bundle.pathForResource(name, ofType: "json")!
		let string = try! String(contentsOfFile: file, encoding: NSUTF8StringEncoding)

		return toJSONObjects(string)!
	}
	
	private func toJSONObjects(string: String) -> AnyObject? {
		
		guard let data = string.dataUsingEncoding(NSUTF8StringEncoding) else {
			
			return nil
		}
		
		return try? NSJSONSerialization.JSONObjectWithData(data, options: [])
	}
	
    func testCase1() {
		
		let objects = readJSON("1")
		let status = try! decode(objects) as ESTwitter.Status
		
		XCTAssertEqual(status.entities?.userMenthions?.first?.idStr, "2546782123")
    }
}
