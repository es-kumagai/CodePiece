//
//  CharacterTests.swift
//  ESTwitterTests
//
//  Created by Tomohiro Kumagai on 2020/02/02.
//  Copyright © 2020 Tomohiro Kumagai. All rights reserved.
//

import XCTest

class CharacterTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testCharacterCount() {

		let s1 = "👨‍👩‍👦‍👦"	// ゼロ幅接合子
		
		XCTAssertEqual(s1.count, 1)
		XCTAssertEqual(s1.utf16.count, 11)
		XCTAssertEqual(s1.twitterCharacterView.first!.wordCount, 1)
		XCTAssertFalse(s1.twitterCharacterView.first!.isEnglish)

		let s2 = "🐲"	// サロゲートペア

		XCTAssertEqual(s2.count, 1)
		XCTAssertEqual(s2.utf16.count, 2)
		XCTAssertEqual(s2.twitterCharacterView.first!.wordCount, 1)
		XCTAssertFalse(s2.twitterCharacterView.first!.isEnglish)

		let s3 = "1️⃣"	// 絵文字シーケンス

		XCTAssertEqual(s3.count, 1)
		XCTAssertEqual(s3.utf16.count, 3)
		XCTAssertEqual(s3.twitterCharacterView.first!.wordCount, 1)
		XCTAssertFalse(s3.twitterCharacterView.first!.isEnglish)

		let s4 = "⭐️"	// 絵文字スタイル化 異体字セレクタ EPVS

		XCTAssertEqual(s4.count, 1)
		XCTAssertEqual(s4.utf16.count, 2)
		XCTAssertEqual(s4.twitterCharacterView.first!.wordCount, 1)
		XCTAssertFalse(s4.twitterCharacterView.first!.isEnglish)

		let s5 = "⭐︎"	// テキストスタイル化する 異体字セレクタ TPVS

		XCTAssertEqual(s5.count, 1)
		XCTAssertEqual(s5.utf16.count, 2)
		XCTAssertEqual(s5.twitterCharacterView.first!.wordCount, 2)
		XCTAssertFalse(s5.twitterCharacterView.first!.isEnglish)

		let s6 = "Z"
		XCTAssertEqual(s6.count, 1)
		XCTAssertEqual(s6.utf16.count, 1)
		XCTAssertEqual(s6.twitterCharacterView.first!.wordCount, 1)
		XCTAssertTrue(s6.twitterCharacterView.first!.isEnglish)

		let s7 = "☃️"
		
		print(s7, s7.utf16.map { String(format: "0x%04X", $0) })

		XCTAssertEqual(s7.count, 1)
		XCTAssertEqual(s7.utf16.count, 2)
		XCTAssertEqual(s7.twitterCharacterView.first!.wordCount, 2)
		XCTAssertFalse(s7.twitterCharacterView.first!.isEnglish)
		
		let s8 = "❣️"

		print(s8, s8.utf16.map { String(format: "0x%04X", $0) })

		XCTAssertEqual(s8.count, 1)
		XCTAssertEqual(s8.utf16.count, 2)
		XCTAssertEqual(s8.twitterCharacterView.first!.wordCount, 2)
		XCTAssertFalse(s8.twitterCharacterView.first!.isEnglish)
	}

}
