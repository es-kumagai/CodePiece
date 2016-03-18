//
//  FontTests.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/07/26.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import XCTest

@testable import CodePiece

class FontTests: XCTestCase {
	
	override func setUp() {
		super.setUp()
		// Put setup code here. This method is called before the invocation of each test method in the class.
	}
	
	override func tearDown() {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
		super.tearDown()
	}
	
	func testFontLoad() {
		
		let textFont = systemPalette.textFont
		let codeFont = systemPalette.codeFont
		
		XCTAssertNotNil(textFont)
		XCTAssertNotNil(codeFont)
	}
}
