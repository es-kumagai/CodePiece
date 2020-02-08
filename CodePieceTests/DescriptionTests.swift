//
//  DescriptionTests.swift
//  CodePieceTests
//
//  Created by Tomohiro Kumagai on 2020/02/09.
//  Copyright © 2020 Tomohiro Kumagai. All rights reserved.
//

import XCTest
@testable import CodePiece
import ESTwitter

class DescriptionTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testDescriptionForTwitter() {

		let data = PostData(code: "", description: "", language: .swift, hashtags: [Hashtag("#CodePiece")], usePublicGists: false, replyTo: nil, appendAppTagToTwitter: true)
		let container = PostDataContainer(data)

		
		// ------------------------------
		container.data.description = "テスト https://www.ez-net.jp/test/サブ%20/tesテス/日本語.html?id=キーkeyきー&value=値ataiあたい テスト"
		
		let d1 = container.makeDescriptionForTwitter(forCountingLength: false)

		// ------------------------------
		container.data.description = "テスト https://www.日本語.jp/test/test.html?id=キーkeyきー&value=値ataiあたい テスト"
		
		let d2 = container.makeDescriptionForTwitter(forCountingLength: false)
		
		// ------------------------------
		container.data.description = "テスト https://ja.wikipedia.org/wiki/インチ テスト"
		
		let d3 = container.makeDescriptionForTwitter(forCountingLength: false)

		// ------------------------------
		container.data.description = "テスト https://ja.wikipedia.org/wiki テスト"
		
		let d4 = container.makeDescriptionForTwitter(forCountingLength: false)

		// ------------------------------
		container.data.description = "テスト https://ja.wikipedia.org/ テスト"
		
		let d5 = container.makeDescriptionForTwitter(forCountingLength: false)

		// ------------------------------
		container.data.description = "テスト https://ja.wikipedia.org テスト"
		
		let d6 = container.makeDescriptionForTwitter(forCountingLength: false)

		// ------------------------------
		container.data.description = "テスト https://ja.wikipedia.org/wiキ テスト"
		
		let d7 = container.makeDescriptionForTwitter(forCountingLength: false)

		// ------------------------------
		container.data.description = "https://www.ez-net.jp/test/サブ%20/tesテス/日本語.html?id=キーkeyきー&value=値ataiあたい"
		
		let d8 = container.makeDescriptionForTwitter(forCountingLength: false)

		// ------------------------------

		// ------------------------------
		container.data.description = "https://www.日本語.jp/test/test.html?id=キーkeyきー&value=値ataiあたい"
		
		let d9 = container.makeDescriptionForTwitter(forCountingLength: false)
		
		// ------------------------------
		container.data.description = "https://ja.wikipedia.org/wiki/インチ"
		
		let d10 = container.makeDescriptionForTwitter(forCountingLength: false)

		// ------------------------------
		container.data.description = "https://ja.wikipedia.org/wiki"
		
		let d11 = container.makeDescriptionForTwitter(forCountingLength: false)

		// ------------------------------
		container.data.description = "https://ja.wikipedia.org/"
		
		let d12 = container.makeDescriptionForTwitter(forCountingLength: false)

		// ------------------------------
		container.data.description = "https://ja.wikipedia.org"
		
		let d13 = container.makeDescriptionForTwitter(forCountingLength: false)

		// ------------------------------
		container.data.description = "https://ja.wikipedia.org/wiキ"
		
		let d14 = container.makeDescriptionForTwitter(forCountingLength: false)

		// ------------------------------

		XCTAssertEqual(d1, "テスト https://www.ez-net.jp/test/%E3%82%B5%E3%83%96%2520/tes%E3%83%86%E3%82%B9/%E6%97%A5%E6%9C%AC%E8%AA%9E.html?id=%E3%82%AD%E3%83%BCkey%E3%81%8D%E3%83%BC&value=%E5%80%A4atai%E3%81%82%E3%81%9F%E3%81%84 テスト #swift #CodePiece")
		XCTAssertEqual(d2, "テスト https://www.日本語.jp/test/test.html?id=%E3%82%AD%E3%83%BCkey%E3%81%8D%E3%83%BC&value=%E5%80%A4atai%E3%81%82%E3%81%9F%E3%81%84 テスト #swift #CodePiece")
		XCTAssertEqual(d3, "テスト https://ja.wikipedia.org/wiki/%E3%82%A4%E3%83%B3%E3%83%81 テスト #swift #CodePiece")
		XCTAssertEqual(d4, "テスト https://ja.wikipedia.org/wiki テスト #swift #CodePiece")
		XCTAssertEqual(d5, "テスト https://ja.wikipedia.org/ テスト #swift #CodePiece")
		XCTAssertEqual(d6, "テスト https://ja.wikipedia.org テスト #swift #CodePiece")
		XCTAssertEqual(d7, "テスト https://ja.wikipedia.org/wi%E3%82%AD テスト #swift #CodePiece")

		XCTAssertEqual(d8, "https://www.ez-net.jp/test/%E3%82%B5%E3%83%96%2520/tes%E3%83%86%E3%82%B9/%E6%97%A5%E6%9C%AC%E8%AA%9E.html?id=%E3%82%AD%E3%83%BCkey%E3%81%8D%E3%83%BC&value=%E5%80%A4atai%E3%81%82%E3%81%9F%E3%81%84 #swift #CodePiece")
		XCTAssertEqual(d9, "https://www.日本語.jp/test/test.html?id=%E3%82%AD%E3%83%BCkey%E3%81%8D%E3%83%BC&value=%E5%80%A4atai%E3%81%82%E3%81%9F%E3%81%84 #swift #CodePiece")
		XCTAssertEqual(d10, "https://ja.wikipedia.org/wiki/%E3%82%A4%E3%83%B3%E3%83%81 #swift #CodePiece")
		XCTAssertEqual(d11, "https://ja.wikipedia.org/wiki #swift #CodePiece")
		XCTAssertEqual(d12, "https://ja.wikipedia.org/ #swift #CodePiece")
		XCTAssertEqual(d13, "https://ja.wikipedia.org #swift #CodePiece")
		XCTAssertEqual(d14, "https://ja.wikipedia.org/wi%E3%82%AD #swift #CodePiece")
	}
}
